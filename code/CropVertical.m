function [ outImg ] = CropVertical( inImg )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

    leftMargin=0;
    topMargin=0;
    rightMargin=size(inImg,2);
    bottomMargin=size(inImg,1);
    
    for r=1:size(inImg,1) - 1
        notBlack=0;
        for c=1:size(inImg,2)
           if(inImg(r,c,1)+inImg(r,c,2)+inImg(r,c,3)~=0)
              notBlack=notBlack+1;               
           end
        end
        if(notBlack==0)
           topMargin=topMargin+1;   
        else
           break;
        end        
    end
    
    for r=size(inImg,1):-1:1
        notBlack=0;
        for c=1:size(inImg,2)
           if(inImg(r,c,1)+inImg(r,c,2)+inImg(r,c,3)~=0)
              notBlack=notBlack+1;               
           end
        end
        if(notBlack==0)
           bottomMargin=bottomMargin-1;  
        else
           break;
        end        
    end

    outImg = imcrop(inImg,[leftMargin topMargin rightMargin bottomMargin]);
     
end


