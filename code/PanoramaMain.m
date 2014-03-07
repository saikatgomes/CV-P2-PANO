function [finalimg] = PanoramaMain(inDir)

    pointsToSample = 4;
    epsilon = 10;
    f=660;

    %startup;
    warning('off','all');
    outDir=strcat(inDir,'PANO_',datestr(now,'mmddyyyy_HHMMSSFFF'));
    mkdir(outDir);
    display(strcat(datestr(now,'HH:MM:SS'),' [INFO] ', ...
        ' Output dir created at ',outDir));
  
    srcFiles = dir(strcat(inDir,'*.*'));  
    for i = 1 : length(srcFiles)
        if (srcFiles(i).isdir~=1)
            inFilename = strcat(inDir,srcFiles(i).name);            
            display(strcat(datestr(now,'HH:MM:SS'),' [INFO] ', ...
                ' Processing file ',inFilename));            
            I = imread(inFilename);            
            NewI = convertToCylindrical(I,f);
            %figure, imshow(NewI);
            outFilename=strcat(outDir,'/cy_',srcFiles(i).name);                       
            display(strcat(datestr(now,'HH:MM:SS'),' [INFO] ', ...
                ' Creating file ',outFilename));  
            imwrite(NewI,outFilename);
        end
    end
    

% % %     %TODO: first read in 2 images from directory
% % %     img1;
% % %     img2;
% % % 
% % %     %TODO: run SiftAndRansac with various pointsToSample and epsilons and
% % %     %choose the best homography matrix based on its determinant etc.
% % % 
% % %     homography = SiftAndRansac(img1, img2, pointsToSample, epsilon);
% % % 
% % %     tform = projective2d(h2);
% % %     warped_img1 = imwarp(img1,tform);

end
