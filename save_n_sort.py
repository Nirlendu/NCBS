import os
input_dir= raw_input ('Enter the directory :')
os.chdir(input_dir)
i=1
files = os.listdir(input_dir)
for var in files :
    rashmi=var.find('s013a001')
    if rashmi != -1:
        os.rename(var,'fmri'+var.split('s013a001')[1])      # renaming based on the file type
        print var
    poortata=var.find('s018')
    if var.endswith('.nii'):
        if poortata != -1:
            if var[0]=='2':
                print var
                os.rename(var,'struc.nii')
            if var[0]=='o':
                os.rename(var,'o_struc.nii')
            else:
                os.rename(var,'co_struc.nii')
    varshaa=var.find('s005')
    if varshaa != -1:
        if var.endswith('.nii'):
            os.rename(var,'DTI'+var.split('s005a001')[1])
            print var





        


    
