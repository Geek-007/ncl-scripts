load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

undef("plotSO2")
procedure plotSO2(historyRun:string,year:string,day_offset:integer)

local historyNames

begin

  historyPattern=historyRun+"/all.*.cam2.h0."+year+"*.nc"
  historyNames = systemfunc("ls " + historyPattern)
  print(historyNames)
  history = addfiles(historyNames, "r")
  ListSetType(history, "cat")
  SO2=addfiles_GetVar(history, historyNames, "SO2")
; SO2[time | 55] x [lev | 66] x [lat | 46] x [lon | 72]
  time = addfiles_GetVar(history, historyNames, "time")
  print(time)
  lev = history[0]->lev
  lat = history[0]->lat
  lon = history[0]->lon
  nlev=dimsizes(lev)

  SO2mean_30N=new(nlev,float)
  SO2mean_30N!0="lev"
  SO2mean_30N&lev=lev
  SO2err_30N=SO2mean_30N
  
  ; get mean and standard deviation at each level
  ; for April - May (days 90-150), 30N, all longitudes
  do i= 0, nlev-1
    SO2mean_30N(i)=avg(SO2({90+day_offset:150+day_offset},i,{30},:))
    SO2err_30N(i)=stddev(SO2({90+day_offset:150+day_offset},i,{30},:))
  end do
  SO2mean_30N=SO2mean_30N*1e12 ; pptv
  SO2err_30N=SO2err_30N*1e12 ; pptv
  
;************************************************
; plotting parameters
;************************************************
  wks   = gsn_open_wks ("pdf","SO2_30N_"+historyRun) ; open workstation

  res                   = True                       ; plot mods desired
  res@gsnFrame               = False                     ; don't draw yet
  res@gsnDraw                = False                     ; don't advance frame
  res@vpHeightF             = 0.6             ; change aspect ratio
  res@vpWidthF              = 0.4
;  res@tiMainString      = "SO2 (pptv)"             ; add title
  res@trYReverse        = True                       ; reverse Y-axis
  res@trYLog            = True                       ; log Y-axis
  res@trXLog            = True                       ; log X-axis
  res@trYMinF           = 0.3
  res@trYMaxF           = 30.0
  res@trXMinF           = 1.0
  res@trXMaxF           = 300.0
  res@tiYAxisString     ="Pressure (hPa)"
  res@tiXAxisString     ="SO2 (pptv)"
  res@xyLineThicknesses = (/1.0,4.0,1.0/)
  res@gsnMaximize       = True
  res@gsnPaperOrientation = "portrait"
;  res@gsnPaperWidth     = 7.0
;  res@gsnPaperHeight    = 14.0
  
  data2      = new((/3,nlev/),float)

  data2(0,:) = SO2mean_30N-SO2err_30N
  data2(1,:) = SO2mean_30N
  data2(2,:) = SO2mean_30N+SO2err_30N

  res@xyDashPattern = 0               ; Make curves all solid
 
  plot  = gsn_csm_xy (wks,data2,lev,res) ; create plot
  
;************************************************
; add observations
;************************************************  
  datapress=(/15.8,10,6.3,3.98,2.51,1.58,1,0.63/)
  datapress2=datapress(1:)

  spacelab=(/9.4,34,70,110,120,140,57/)
  spacelaberr=(/6,17,35,60,60,100,30/)

  atlas1=(/13,33,88,260,380,350,400,460/)
  atlas1err=(/4,6,17,50,80,70,70,110/)

  atlas2=(/22,45,100,180,240,280,250/)
  atlas2err=(/9,10,31,70,80,70,70/)
  
  polyres                   = True                       ; marker resources
  polyres@gsMarkerIndex     = 1                          ; index for circle
  polyres@gsMarkerSizeF     = .02                        ; size 
  
; gsn_add* templates are functions that we set to dummy values. Since
; we are going to draw numerous error bars, we create two arrays to
; hold the dummy values.
  spacelab_bar = new(dimsizes(spacelab),graphic)
  spacelab_centers   = new(dimsizes(spacelab),graphic)

; loop through the points  
  do t=0,dimsizes(spacelab)-1
; add a polymarker as the center of the error bar located at each data
; point
    spacelab_centers(t)   = gsn_add_polymarker(wks,plot,spacelab(t),\
      datapress2(t),polyres)
; the error bar is draw in two segements, above and below the true
; value of u(t). I made up these value. You would change this to 
; true error.      
    spacelab_bar(t) = gsn_add_polyline(wks,plot,(/spacelab(t)-spacelaberr(t),\
      spacelab(t)+spacelaberr(t)/), (/datapress2(t),datapress2(t)/),polyres)
  end do
  draw(plot)
  frame(wks)

end

;plotSO2("coag04","1995-0[45]",0)
;plotSO2("coag04-2","1996-0[345]",365)
;plotSO2("nopur2_ncar","1995-0[45]",0)
plotSO2("JPL06_ncar","1995-0[45]",0)