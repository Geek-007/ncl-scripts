load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

undef("calcSizeDistN2O")
procedure calcSizeDistN2O(caseid:string, startyear:integer, endyear:integer, hem:string)

; input variables
;    caseid      : e.g "b.e12.B55TRW5CN.f19_g16.Pin10Tg.20-25km.15S-15N.zavg.QBOon.003"  
;    startyear, endyear : integer year range, e.g. 1992, 1993
;    hem         : hemisphere, e.g. "NH", "global"
;    N2Oppb      : N2O bounds in descending order, e.g. (/ 300, 250, 200, 150, 100, 50 /)

; output variables
;    DpMean         : Bin geometric mean diameters
;    dVdlog10Dp_avg : normalized mean volume distribution 
;    dVdlog10Dp_std : normalized standard deviation about the mean volume distribution
  
begin
  pi      = 4.0 * atan(1.0) 
  sqrt2pi=sqrt(2*pi)

  if (startyear.gt.endyear) then
    print("FATAL: startyear = "+startyear+" > endyear = "+endyear)
    status_exit(1)
  end if

  print("startyear = "+startyear+", endyear = "+endyear)

  if (startyear.eq.endyear) then
    rangestr=startyear
  else
    rangestr=startyear+"-"+endyear
  end if

  rootpath = "/glade/scratch/mmills/archive/"
  
  exists =isfilepresent(rootpath+caseid+"/atm/proc/h0zm/")
  if (.not.exists) then
    print("Missing: "+rootpath+caseid+"/atm/proc/h0zm/")
    rootpath="/glade/p/cesm/wawg_dev/mmills/archive/"
  end if
  
  exists =isfilepresent(rootpath+caseid+"/atm/proc/h0zm/")
  if (.not.exists) then
    print("Missing: "+rootpath+caseid+"/atm/proc/h0zm/")
    print("FATAL: check caseid="+caseid)
    status_exit(1)
  end if
  print("Rootpath: "+rootpath+caseid+"/atm/proc/h0zm/")

  if (hem.eq."NH") then
    lat1=0
    lat2=90
  else
    lat1=-90
    lat2=90
  end if  
  

  N2Oppb = (/ 300, 250, 200, 150, 100, 50 /)
  N2Oppb@long_name="N2O boundaries"
  N2Oppb@units="ppbv"
  
  nBounds = dimsizes(N2Oppb)
  nRanges = nBounds-1
  
  dlog10Dp = 0.056268 ; bin width of Wilson FCAS measurements

  ; Bin geometric mean diameters for Wilson FCAS measurements:
  DpMean = (/ 0.064015516,0.072870752,0.082950928,0.094425491,0.107487324, \
              0.122355994,0.139281441,0.158548176,0.18048007,0.205445792, \
              0.233865011,0.266215446,0.303040902,0.344960406,0.392678615, \
              0.446997661,0.508830634,0.579216934,0.659339737,0.750545889, \
              0.854368544,0.972552939,1.107085724,1.260228365,1.434555155, \
              1.632996487,1.858888114,2.116027222,2.40873626,2.741935601, \
              3.121226247,3.5, 4. , 4.5, 5. /)
  DpMean@units="um"
  
  nBins = dimsizes(DpMean)
  log10DpMean = log10(DpMean)

;  sigmag=(/1.6, 1.6, 1.8/) ; geometric standard deviations for 3 MAM3 modes
  sigmag=(/1.6, 1.6, 1.2/) ; geometric standard deviations for 3 MAM3 modes
  log10sigmag=log10(sigmag)
    
  N2Oppb2=N2Oppb(0:nRanges-1)
  
  dVdlog10Dp_avg=new((/nRanges,nBins/),"float")
  dVdlog10Dp_avg!0="N2O"
  dVdlog10Dp_avg&N2O=N2Oppb2
  dVdlog10Dp_avg!1="diameter"
  dVdlog10Dp_avg&diameter=DpMean
  
  dVdlog10Dp_std=dVdlog10Dp_avg
  
  outfilename=rootpath+caseid+"/atm/proc/SizeDistN2O_"+rangestr+"_"+hem+".nc"
  dum=systemfunc("rm "+outfilename)
  outfile=addfile(outfilename,"c")

  historyPattern=rootpath+caseid+"/atm/proc/h0zm/"
  historyNames1 = systemfunc("ls " + historyPattern)
  ; select only files between startyear and endyear
  col1=strlen(caseid+".cam.h0zm.")
  col2=col1+3
  yearstr=str_get_cols(historyNames1,col1,col2)
;  print(yearstr+" : "+historyNames1)
  year=stringtointeger(yearstr)
  yi=ind(year.ge.startyear.and.year.le.endyear)
  historyNames=historyNames1(yi)
  print("historyNames:"+dimsizes(historyNames))

  history = addfiles(rootpath+caseid+"/atm/proc/h0zm/"+historyNames, "r")
  ListSetType(history, "cat")

  print("reading N2O")
  N2O = history[:]->N2O

  ; dry diameter not saved, but wet should be the same as dry for these runs
  print("reading dgnd_a01")
  dgnum1 = history[:]->dgnd_a01
  print("reading dgnd_a02")
  dgnum2 = history[:]->dgnd_a02
  print("reading dgnd_a03")
  dgnum3 = history[:]->dgnd_a03
  print("reading num_a1")
  num_a1 = history[:]->num_a1
  print("reading num_a2")
  num_a2 = history[:]->num_a2
  print("reading num_a3")
  num_a3 = history[:]->num_a3

  dg1=ndtooned(dgnum1(:,:,{lat1:lat2}))
  dg2=ndtooned(dgnum2(:,:,{lat1:lat2}))
  dg3=ndtooned(dgnum3(:,:,{lat1:lat2}))

  n1=ndtooned(num_a1(:,:,{lat1:lat2}))
  n2=ndtooned(num_a2(:,:,{lat1:lat2}))
  n3=ndtooned(num_a3(:,:,{lat1:lat2}))

  printVarSummary(N2O(:,:,{lat1:lat2})) ; [time | 24] x [lev | 70] x [lat | 96]
  ds=dimsizes(N2O(:,:,{lat1:lat2}))

  N2O_1D = ndtooned(N2O(:,:,{lat1:lat2}))
  N2Obounds=N2Oppb*1.e-9
  N2Obounds@units=N2O@units
  N2Obounds@long_name="N2O boundaries"
  
  do n = 0, nRanges-1
    np1=n+1
    print("    ")
    print("=========================================================================")
;    print(N2Oppb)
;    print(n+" "+np1)
    print(np1+" of "+nRanges+": N2O range "+N2Oppb(n)+" to "+N2Oppb(np1))
    if (N2Oppb(n).le.N2Oppb(n+1)) then
      print("calcSizeDistN2O error: N2Oppb must be in descending order. Aborting.")
      print(N2Oppb)
      status_exit(1)
    end if
    
    iN2O = ind(N2O_1D.lt.N2Obounds(n).and.N2O_1D.gt.N2Obounds(n+1))

;    printVarSummary(iN2O)
    nN2O = dimsizes(iN2O)

    log10dgvol=new((/3,nN2O/),"float")
    numarr=log10dgvol

    log10dgvol(0,:) = log10(dg1(iN2O)*1e6) + 3*log10sigmag(0)*log10sigmag(0)
    log10dgvol(1,:) = log10(dg2(iN2O)*1e6) + 3*log10sigmag(1)*log10sigmag(1)
    log10dgvol(2,:) = log10(dg3(iN2O)*1e6) + 3*log10sigmag(2)*log10sigmag(2)

    numarr(0,:) = ndtooned(n1(iN2O))
    numarr(1,:) = ndtooned(n2(iN2O))
    numarr(2,:) = ndtooned(n3(iN2O))

    sizedist=new((/nBins,nN2O/),"float")
    sizedist(:,:)=0.0

    do t = 0, nN2O-1
      if (mod(t,1000).eq.0) then
        print(t+" of "+nN2O)
      end if
      do i = 0, nBins-1
        do m=0,2 ; modes
          dVdlog10Dp=3.0*log10DpMean(i)+(9./2.)*log10sigmag(m)*log10sigmag(m)
          dVdlog10Dp=dVdlog10Dp-(((log10DpMean(i)-log10dgvol(m,t))/log10sigmag(m))^2.)/2
          dVdlog10Dp=numarr(m,t)/DpMean(i)/log10sigmag(m)*10^dVdlog10Dp
          sizedist(i,t)=sizedist(i,t)+dVdlog10Dp
        end do
      end do
      ; normalize distribution
      sizedist(:,t)=sizedist(:,t)/sum(sizedist(:,t))/dlog10Dp
    end do

    print("calculating average")
    dVdlog10Dp_avg(n,:)=dim_avg(sizedist)
    print("calculating standard deviation")
    dVdlog10Dp_std(n,:)=dim_stddev(sizedist)
    
    delete(iN2O)
    delete(nN2O)
    delete(log10dgvol)
    delete(numarr)
    delete(sizedist)
    delete(dVdlog10Dp)
    
  end do
  
  print("writing output")
  outfile->N2Oppb=N2Oppb
  outfile->N2Obounds=N2Obounds
  outfile->dVdlog10Dp_avg=dVdlog10Dp_avg
  outfile->dVdlog10Dp_std=dVdlog10Dp_std
  
end

caseid=getenv("caseid")

if (ismissing(caseid)) then
  print("FATAL: caseid environment variable not set")
  status_exit(1)
else
  print("caseid: "+caseid)
end if

; Standard year ranges: 1992-1993, 1996-1997, 1999-2000, 2002-2003
startyear=stringtoint(getenv("startyear"))
endyear=stringtoint(getenv("endyear"))

if (ismissing(startyear)) then
  startyear=1992
end if  

if (ismissing(endyear)) then
  endyear=1993
end if

hem="NH"

;dgVar = "dgnumwet"
;dgVar = "dgnd_a0"
calcSizeDistN2O(caseid, startyear, endyear, hem)

