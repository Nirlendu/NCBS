#sorts the dicom files according to the types

import dicom
import os
import shutil


name=raw_input("Enter the path: ")

folder= ['t1_fl3d_tra_1MM','act_MoCoSeries','ep2d_diff_mddw_20_p2(DTI)_TRACEW','ep2d_bold_moco_p2','ep2d_diff_mddw_20_p2(DTI)_ColFA','ep2d_diff_mddw_20_p2(DTI)_FA','ep2d_diff_mddw_20_p2(DTI)_TENSOR','ep2d_diff_mddw_20_p2(DTI)_ADC','ep2d_diff_mddw_20_p2(DTI)','Design','t2_tirm_tra_dark-fluid','gre_field_mapping','Mean_&_t-Maps','EvaSeries_GLM','Pha_Images','Mag_Images','mIP_Images(SW)']


home_dir="/home/skullboy/dicom"



for fol in folder:
     	os.makedirs(home_dir+ "/" +fol)



os.chdir(name)
files= os.listdir(name)
for nam in files:
		x = dicom.read_file(nam)
		shutil.copy2(name+"/"+nam,home_dir+"/"+x.SeriesDescription,)


