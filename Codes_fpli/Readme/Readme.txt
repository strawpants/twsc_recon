These codes are used to reconstruct and predict the GRACE-like gridded total water storage  
changes over the Amazon basin using three kinds of climate inputs (details can be found in
the publication). Four ’run‘ programs are provided as listed below but I recommend to start 
with the "Run_Ama_LS_test.m" or "Run_Ama_STL_test.m" because they have more detailed 
comments. All input data are included so you can run these four programs directly. 

Note:Reading the paper "Comparison of Data-driven Techniques to Reconstruct (1992-2002) 
and Predict (2017-2018) GRACE-like Gridded Total Water Storage Changes using Climate Inputs" 
could help a new learner to better understand these codes.

-Run:
Run_Ama_LS_test.m
Run_Ama_STL_test.m
Run_Ama_LS_pre.m
Run_Ama_LS_re.m

-Function list:
ANN_TEST.m
ARX_TEST.m
jadeR.m
los_reg_extend.m
los_reg.m
LS.m
multi_regress_or.m
multi_regress_pre.m
multi_regress.m
myfun.m

-Data list:
2001_COBE_SST.mat
2001_CPC_Precip_Mon.mat
2001_land_temp.mat
2002_CPC_Precip_daily.mat
199110_201709_CPC_P_Daily.mat
199110_201709_CPC_P_Mon.mat
199110_201709_SST_NOAA.mat
199110_201709_temp.mat
200201_201903_CPC_P_Daily.mat
200201_201903_CPC_P_Mon.mat
200201_201903_SST_NOAA.mat
200201_201903_temp.mat
CSR_interpo.mat

-boundary list:
amazon_new.bln
Baltic.bln
Blacksea.bln
Danube.bln
Hudson.bln
Indian.bln
Mediterranean1.bln
Mediterranean2.bln
Mississippi.bln
NAtlantic.bln
NGBsea1.bln
NGBsea2.bln
NNAtlantic1.bln
NNAtlantic2.bln
NPacific.bln
SAtlantic1.bln
SAtlantic2.bln
SPacific.bln