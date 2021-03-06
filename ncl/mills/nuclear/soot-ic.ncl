load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
; Soot Tests
;
; Create some tracer distributions for use with WACCM/CARMA.

host   = systemfunc("hostname")
print("hostname:"+host)
WACCM_RES = getenv("WACCM_RES")
MODEL_PATH = getenv("MODEL_PATH")

if (ismissing(WACCM_RES)) then
  WACCM_RES  = "2x2.5"
;  WACCM_RES  = "4x5"
end if
print("Using " + WACCM_RES + " resolution ...")

;caseid = "b40.rcp4_5.2deg.wcm.carma.bc0tg.001"
;year = 2013
;newcase="b40.rcp4_5.2deg.wcm.carma.bc5tg.IndPak.001"

caseid = "b40.rcp4_5.2deg.wcm.carma.bc0tg.006"
year = 2023
newcase="b40.rcp4_5.2deg.wcm.carma.bc5tg.IndPak.006"

if (isStrSubset(host,"lfe")) then
  ; lou
  PATH="~/csm/"+caseid+"/rest/"+year+"-01-01-00000/"
else
;  PATH=MODEL_PATH+"/ccsm/inputdata/atm/waccm/ic"
  PATH="/glade/p/acd/mmills/run/"+caseid+"/rest/"+year+"-01-01-00000/"
end if

print("PATH="+PATH)

;load "soot.ncl" ; for 0Tg ICs (comment out otherwise)
load "ic-BC-IndPak.ncl" ; for India-Pakistan ICs (comment out otherwise)

print("Resolution: " + WACCM_RES)

;if (WACCM_RES .eq. "10x15") then 
;  newic("data/atm/cam/inic/fv", "cami_0000-01-01_10x15_L26_c030918.nc", "output.nc")
;end if

;if (WACCM_RES .eq. "4x5") then 
;;  newic("data/atm/waccm/ic/wa3_4x5_1950_spinup.cam2.i.1960-01-01-00000.nc")
;  newic("/home/mills/waccm/data/wa319_smax", \
;        "waccm319_8_smaxa.cam2.i.2025-01-01-00000.nc", \
;        "waccm319_8_smaxa_soot5Tg.cam2.i.2025-01-01-00000.nc", \
;        1.8031e-5)
;end if

if (WACCM_RES .eq. "2x2.5") then 
;  newic("data/atm/waccm/ic/wa3_4x5_1950_spinup.cam2.i.1960-01-01-00000.nc")

;  newic(PATH, \
;       "f2000.e10r02.2deg.waccm.005.cam2.i.0017-01-01-00000.nc", \
;       "f40.2000.2deg.waccm.carma.bc5_0tg.cam2.i.0017-01-01-00000.nc", \
;       4.50775e-06)

;  newic(PATH, \
;       "b40.2000.2deg.wcm.carma.bc.002.0Tg.cam2.i.0001-05-15-00000.nc", \
;       "b40.2000.2deg.wcm.carma.bc.002.5Tg_4x5.cam2.i.0001-05-15-00000.nc", \
;       5.0, 4.0, 5.0)

;  newic(PATH, \
;       "b40.2000.2deg.wcm.carma.bc.002.0Tg.cam2.i.0001-05-15-00000.nc", \
;       "b40.2000.2deg.wcm.carma.bc.002.5Tg_8x10.cam2.i.0001-05-15-00000.nc", \
;       5.0, 8.0, 10.0)

;  newic(PATH, \
;       "b40.2000.2deg.wcm.carma.bc.002.0Tg.cam2.i.0001-05-15-00000.nc", \
;       "b40.2000.2deg.wcm.carma.bc.002.1Tg.cam2.i.0001-05-15-00000.nc", \
;       1.0)

;  newic(PATH, \
;       "b40.rcp4_5.2deg.wcm.carma.bc0tg.001.cam2.i.2012-05-15-00000.nc", \
;       "b40.rcp4_5.2deg.wcm.carma.bc5tg.IndPak.cam2.i.2012-05-15-00000.nc", \
;       5.0)

;  newic("/u/mjmills2/csm/b40.rcp4_5.2deg.wcm.003/rest/2012-01-01-00000", \
;       "b40.rcp4_5.2deg.wcm.003.cam2.i.2012-01-01-00000.nc", \
;       "b40.rcp4_5.2deg.wcm.carma.bc0tg.003.cam2.i.2012-01-01-00000.nc", \
;       0.0)

;  newic("/nobackup/mjmills2/ccsmdata/inputdata/ccsm4_init/b40.rcp4_5.2deg.wcm.001/2012-01-01", \
;       "b40.rcp4_5.2deg.wcm.001.cam2.i.2012-01-01-00000.nc", \
;       "b40.rcp4_5.2deg.wcm.carma.bc0tg.001.cam2.i.2012-01-01-00000.nc", \
;       0.0)

; 2/23/2011       
;  newicBCIndPak("/nobackup/mjmills2/ccsmdata/inputdata/ccsm4_init/b40.rcp4_5.2deg.wcm.carma.bc0tg.001/2013-01-01", \
;       "b40.rcp4_5.2deg.wcm.carma.bc0tg.001.cam2.i.2013-01-01-00000.nc", \
;       "b40.rcp4_5.2deg.wcm.carma.bc5tg.IndPak.001.cam2.i.2013-01-01-00000.nc", \
;       5.0d0)

  newicBCIndPak(PATH, \
       caseid+".cam2.i."+year+"-01-01-00000.nc", \
       newcase+".cam2.i."+year+"-01-01-00000.nc", \
       5.0d0)


end if
