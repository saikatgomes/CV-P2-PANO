function [matches] = PanoramaMain(inDir, f)
    
    pointsToSample = 4;
    epsilon = 10;
    %f=660;
    DO_FLAG=1;
    startup;
    srgStartup;
    warning('off','all');
    outDir=strcat(inDir,'PANO_',datestr(now,'mmddyyyy_HHMMSSFFF'));
    mkdir(outDir);
    display(strcat(datestr(now,'HH:MM:SS'),' [INFO] ', ...
        ' Output dir created at ',outDir));
    
    srcFiles = dir(strcat(inDir,'*.*')); 
    count=0;
    for i = 1 : length(srcFiles)
        if (srcFiles(i).isdir~=1)
            count=count+1;
            inFilename = strcat(inDir,srcFiles(i).name);            
            display(strcat(datestr(now,'HH:MM:SS'),' [INFO] ', ...
                ' Processing file>',inFilename));            
            I = imread(inFilename);            
            NewI = convertToCylindrical(I,f);
            outFilename=strcat(outDir,'/cy_',srcFiles(i).name);  
            
            for r=1:size(NewI,1)
                for c=1:size(NewI,2)
                    pixArray(count,r,c,1)=NewI(r,c,1);
                    pixArray(count,r,c,2)=NewI(r,c,2);
                    pixArray(count,r,c,3)=NewI(r,c,3);
                end
            end            
            
            display(strcat(datestr(now,'HH:MM:SS'),' [INFO] ', ...
                ' Creating file>',outFilename));  
            NewI=cropImg(NewI);
            imwrite(NewI,outFilename);
        end
    end    
    
    if(DO_FLAG==1)   
        
        for ii=1: size(pixArray,1)-1
        
            clear I1;
            clear I2;
            clear I1_ori;
            clear I2_ori;
            clear f;
            clear f2;
            clear d;
            clear d2;
            clear fx1;
            clear fx2;
            clear dx1;
            clear dx2;
            clear img2;

            for r=1:size(pixArray,2)
                for c=1:size(pixArray,3)
                    I1(r,c,1)=pixArray(ii,r,c,1);
                    I1(r,c,2)=pixArray(ii,r,c,2);
                    I1(r,c,3)=pixArray(ii,r,c,3);
                    I2(r,c,1)=pixArray(ii+1,r,c,1);
                    I2(r,c,2)=pixArray(ii+1,r,c,2);
                    I2(r,c,3)=pixArray(ii+1,r,c,3);
                end
            end        

            I1=cropImg(I1);
            I2=cropImg(I2);
            I1_ori=I1;
            I2_ori=I2;      

            I1 = single(rgb2gray(I1)) ;
            [f,d] = vl_sift(I1) ;
            I2 = single(rgb2gray(I2)) ;
            [f2,d2] = vl_sift(I2) ;

            [matches, scores] = vl_ubcmatch(d, d2, 2.5) ;        

            for i=1:size(matches,2)
                i1=matches(1,i);
                i2=matches(2,i);
                fx1(:,i)=f(:,i1);
                fx2(:,i)=f2(:,i2);
                dx1(:,i)=d(:,i1);
                dx2(:,i)=d2(:,i2);
            end        

            img2=zeros(size(I1_ori,1),size(I1_ori,2)+size(I2_ori,2),3);
            for i=1:size(I2_ori,1)
               for j=1:size(I2_ori,2)
                  img2(i,j,:)=I1_ori(i,j,:);
                  img2(i,j+size(I1_ori,2),:)=I2_ori(i,j,:);
               end
            end    

            handle = figure ;
            imshow(uint8(img2));
            hold on        
            clear fx1;
            clear fx2;
            clear fy1;
            clear fy2;

            for i=1:size(matches,2)
                i1=matches(1,i);
                i2=matches(2,i);
                fx1=f(1,i1);
                fx2=f2(1,i2)+size(I1_ori,2);
                fy1=f(2,i1);
                fy2=f2(2,i2);
                p1 = [fx1,fx2];
                p2 = [fy1,fy2];
                line(p1,p2,'Color','r','LineWidth',1);
            end

            hold off
            saveas(handle,strcat(outDir,'/switch_',num2str(ii),'.jpg'));

        end
               
    end
        
    
    
    stitchedImg = CreateStitchedImage(pixArray);
    imshow(stitchedImg);
    %CreateStitchedImage(pixArray, outDir);

    
    %display(matches);
    %display(scores);
    
% % % % % %     figure
% % % % % %     
% % % % % %     I2 = single(rgb2gray(I2)) ;
% % % % % %     [f2,d2] = vl_sift(I2) ;
% % % % % %     
% % % % % %     perm2 = randperm(size(f2,2)) ;
% % % % % %     
% % % % % %     display(perm2);
% % % % % %     sel2 = perm2(1:50) ;
% % % % % %     display(sel2);
% % % % % %     
% % % % % %     h4 = vl_plotframe(f2(:,sel2)) ;
% % % % % %     h5 = vl_plotframe(f2(:,sel2)) ;
% % % % % %     
% % % % % %     set(h4,'color','k','linewidth',3) ;
% % % % % %     set(h5,'color','y','linewidth',2) ;
% % % % % %     
% % % % % %     h6 = vl_plotsiftdescriptor(d2(:,sel2),f2(:,sel2)) ;
% % % % % %     set(h6,'color','g') ;
    
    
% % % %     gray1 = GetGrayImageFrom3DArray(I1);
% % % %     gray2 = GetGrayImageFrom3DArray(I2);
% % % %     imshow(uint8(gray1));
% % % %     figure;
% % % %     imshow(uint8(gray2));
% % % %     
% % % %     %the sift arrays will be 4 x featurenum arrays
% % % %     sift1 = vl_sift(gray1);
% % % %     sift2 = vl_sift(gray2);
% % % %     
% % % %     
% % % %     matcharr = vl_ubcmatch(sift1, sift2, threshold);

    
% % % 
% % %     %TODO: run SiftAndRansac with various pointsToSample and epsilons and
% % %     %choose the best homography matrix based on its determinant etc.
% % % 
% % %     homography = SiftAndRansac(img1, img2, pointsToSample, epsilon);
% % % 
% % %     tform = projective2d(h2);
% % %     warped_img1 = imwarp(img1,tform);

end
