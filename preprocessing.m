%function preprocessing_batch(Config_File)
%subjID=fm00223
%%  0.specify data directory
function preprocessing(Config_File)
Config_File = strtrim(Config_File);
if(exist(Config_File,'file')==0)
  fprintf('Cannot find the configuration file ... \n');
  diary off; return;
end
Config_File = Config_File(1:end-2);
eval(Config_File);
%clear Config_File;
%clear matlabbatch
%display(Config_File);


inputdirr=inputdirec;
%subjI=sub;
cd(sub); 
%var={sub,'subject.m'};
eval('subject');
subjI=subjectss;
display(subjI);

%cd(inputdir);
%list = dir([inputdir,'\run*']);
%display(inputdir);


%% 1.slice timing correction
%clear matlabbatch
for j= 1:length(subjI)
  
		%display(length(subjI));
		subjID=subjI{j};
		inputdir=[inputdirr,subjID(1:end),'\task'];
		display(inputdir);
		cd(inputdir);
        list = dir([inputdir,'\run*']);
		display(list);
		cd ..
		dire = pwd;
		cd(inputdir);
		clear matlabbatch
	
		matlabbatch{1}.spm.temporal.st.nslices = nslicess;
		display(nslicess);
		matlabbatch{1}.spm.temporal.st.tr = tri;
		tr = matlabbatch{1}.spm.temporal.st.tr;
		nslices = matlabbatch{1}.spm.temporal.st.nslices;
		matlabbatch{1}.spm.temporal.st.ta = tr - (tr/nslices);
		matlabbatch{1}.spm.temporal.st.so = so;
		matlabbatch{1}.spm.temporal.st.refslice = refslice;
		for i = 1:length(list)
		scans_temp = [];
				scanslist = dir([inputdir,'\run',int2str(i),'\fm*.nii'])
				for k = 1:length(scanslist)
					scans_temp{k} = [inputdir,'\run',int2str(i),'\',scanslist(k).name,',1'];
				end
				scans{i} = scans_temp;

		end

		% fill in fields of structure matlabbatch
		matlabbatch{1}.spm.temporal.st.scans = scans;
		%display(scans);



		% save batch file for review
		savefile = ['slicetime_',subjID];
		save(savefile,'matlabbatch')

		% run batch
		spm_jobman('run',matlabbatch)




		%% 2.realign and unwarp
		clear matlabbatch

		% loop the runs
		for i = 1:length(list)
		   
		  
			   
				scans = [];
			   % temporal corrected files has prefix 'a'
				scanslist = dir([inputdir,'\run',int2str(i),'\afm*.nii']);
				for k = 1:length(scanslist)
					scans{k} = [inputdir,'\run',int2str(i),'\',scanslist(k).name,',1'];
				end
				
				matlabbatch{1}.spm.spatial.realignunwarp.data(i).scans = scans';
		end

		% save batch file
		savefile = ['realignunwarp_a_',subjID];
		save(savefile,'matlabbatch')

		% run batch
		spm_jobman('run',matlabbatch)






		%% 3. co-registration
		%  here anatomical image is co-registered to functional image
		clear matlabbatch
		% specify reference file, the file you want to co-register other files to 
		luo=dir(['run1\mean*.nii']);
		matlabbatch{1}.spm(1).spatial.coreg.estimate.ref = {[inputdir,'\run1\',luo.name]};
		cd ..
		dire = pwd;
		matlabbatch{1}.spm(1).spatial.coreg.estimate.source = {[dire,'\struc\anat.nii,1']};
		cd(inputdir);
		% specify the files that you want to apply the transformation to
		%matlabbatch{1}.spm(1).spatial.coreg.estimate.other = {[inputdir,'\fM',subjID,'-anat.nii,1']};


		% save batch file
		savefile = ['coreg_',subjID];
		save(savefile,'matlabbatch')

		% run batch
		spm_jobman('run',matlabbatch)



		%% 4. segmentation
		clear matlabbatch

		% from which we get sub*-anat_seg_sn_mat. it save the transformation
		% the file to be segmented. need to be an anatomical image
		%matlabbatch{1}.spm.spatial.preproc.data = {[inputdir,'\fM',subjID,'-anat.nii,1']};
		%matlabbatch{1}.spm.spatial.preproc.data = {['C:\Users\Skullboy\Desktop\dataset\sM00223\sM00223_002.nii,1']};
		matlabbatch{1}.spm.spatial.preproc.data ={[dire,'\struc\anat.nii,1']};

		% 'mni' for caucasian brains and 'eastern' for Asian brains
		matlabbatch{1}.spm.spatial.preproc.opts.regtype = 'mni';

		% save batch
		savefile = ['segment_',subjID];
		save(savefile,'matlabbatch')
		% run batch
		spm_jobman('run',matlabbatch)


		%% 5. normalise
		clear matlabbatch



		scans = [];
		%display('hey');
		% specify images that need transformation
		for i = 1:length(list)
		scans_temp = [];
			   
				scanslist = dir([inputdir,'\run',int2str(i),'\uafm*.nii'])
				%display("hey");
				for k = 1:length(scanslist)
					scans_temp{k} = [inputdir,'\run',int2str(i),'\',scanslist(k).name,',1'];
				end
				scans = [scans scans_temp];
				


		end
		anat_image{1}=[dire,'\struc\anat.nii,1'];
		%display(dire);
		%display(anat_image{1});

		scans = [scans anat_image];

		% specify the transformation you want to apply
		%lal=dir('\struc\s*.nii');
		%leng=length(lal);
		%lal=lal{0:leng-4};
		matlabbatch{1}.spm.spatial.normalise.write.subj.matname = {[dire,'\struc\anat_seg_sn.mat']};
		matlabbatch{1}.spm.spatial.normalise.write.subj.resample = scans;
		%matlabbatch{1}.spm.spatial.normalise.write.roptions.bb = [-78  -112   -112;78    76    85];
		matlabbatch{1}.spm.spatial.normalise.write.roptions.bb =bb;
		%matlabbatch{1}.spm.spatial.normalise.write.roptions.prefix = 'w';
		matlabbatch{1}.spm.spatial.normalise.write.roptions.prefix = prefix;

		% save batch
		savefile = ['normalise_',subjID];
		save(savefile,'matlabbatch')
		% run batch
		spm_jobman('run',matlabbatch)




		%% 6. smooth

		clear matlabbatch
		scans = [];

		for i = 1:length(list)
		scans_temp = [];
			   
				scanslist = dir([inputdir,'\run',int2str(i),'\wuafm*.nii'])
				for k = 1:length(scanslist)
					scans_temp{k} = [inputdir,'\run',int2str(i),'\',scanslist(k).name,',1'];
				end
				scans = [scans scans_temp];


		end
		matlabbatch{1}.spm.spatial.smooth.data = scans;
		% specify smoothing kernel
		%matlabbatch{1}.spm.spatial.smooth.fwhm = [8 8 8];
		matlabbatch{1}.spm.spatial.smooth.fwhm = smooth_fwhm;
		% save batch
		savefile = ['smooth_',subjID];
		save(savefile,'matlabbatch')

		% run batch
		spm_jobman('run',matlabbatch)
		clear matlabbatch;
	end
end
%% 99. delete intermediate files
% to save space
%for i = 1:length(list)
 %   cd([inputdir,'\',list(i).name])
 %   delete('sub*.nii')
 %   delete('asub*.nii')
 %   delete('uasub*.nii')
 %   delete('wuasub*.nii') 
%	end
