#Checks for the zipped files and unzips them

import os,sys,zipfile

path= raw_input('Enter the path: ')
fol1=os.listdir(path)
for fold1 in fol1:
  fol2=os.listdir(path+'/'+fold1)
	for fold2 in fol2:
		fol3=os.listdir(path+'/'+fold1+'/'+fold2)
		for fold3 in fol3:
			zfile=zipfile.ZipFile(fold3)
			for name in zfile.namelist():
				(dirname,filename)=os.path.split(name)
				print "Decompressing " + filename + " on " + dirname
				if not os.path.exists(dirname):
					os.mkdir(dirname)
				fd = open(name,"w")
				fd.write(zfile.read(name))
				fd.close()
