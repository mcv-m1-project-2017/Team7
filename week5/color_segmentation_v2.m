function     im_seg=color_segmentation_v2(im,space,segmentation_values,stdr)

    switch space
        case 'RGB'
            %Means and Standards deviations of blue pixels from training signals.
                b_pixel_r_mean=segmentation_values(1);
                b_pixel_r_std=segmentation_values(2)*stdr;
                b_pixel_g_mean=segmentation_values(3);
                b_pixel_g_std=segmentation_values(4)*stdr;
                b_pixel_b_mean=segmentation_values(5);
                b_pixel_b_std=segmentation_values(6)*stdr;

                %Means and Standards deviations of red pixels from training signals.
                r_pixel_r_mean=segmentation_values(7);
                r_pixel_r_std=segmentation_values(8)*stdr;
                r_pixel_g_mean=segmentation_values(9);
                r_pixel_g_std=segmentation_values(10)*stdr;
                r_pixel_b_mean=segmentation_values(11);
                r_pixel_b_std=segmentation_values(12)*stdr;

                %Means and Standards deviations of the blue/red and blue/green ratios of blue pixels from training signals.
                b_pixel_br_ratio_mean=segmentation_values(13);
                b_pixel_br_ratio_std=segmentation_values(14)*stdr;
                b_pixel_bg_ratio_mean=segmentation_values(15)*stdr;
                b_pixel_bg_ratio_std=segmentation_values(16)*stdr;

                %Means and Standards deviations of the red/green and red/blue ratios of red pixels from training signals.
                r_pixel_rg_ratio_mean=segmentation_values(17);
                r_pixel_rg_ratio_std=segmentation_values(18)*stdr;
                r_pixel_rb_ratio_mean=segmentation_values(19);
                r_pixel_rb_ratio_std=segmentation_values(20)*stdr;
                
                
             im_seg=((double(im(:,:,3))./double(im(:,:,1))>(b_pixel_br_ratio_mean-b_pixel_br_ratio_std))...
                & (double(im(:,:,3))./double(im(:,:,1))<(b_pixel_br_ratio_mean+b_pixel_br_ratio_std))...
                & (double(im(:,:,3))./double(im(:,:,2))>(b_pixel_bg_ratio_mean-b_pixel_bg_ratio_std))...
                & (double(im(:,:,3))./double(im(:,:,2))<(b_pixel_bg_ratio_mean+b_pixel_bg_ratio_std))...
                & (im(:,:,1)>(b_pixel_r_mean-b_pixel_r_std)) & (im(:,:,1)<(b_pixel_r_mean+b_pixel_r_std))...
                & (im(:,:,2)>(b_pixel_g_mean-b_pixel_g_std)) & (im(:,:,2)<(b_pixel_g_mean+b_pixel_g_std))...
                & (im(:,:,3)>(b_pixel_b_mean-b_pixel_b_std)) & (im(:,:,3)<(b_pixel_b_mean+b_pixel_b_std)))...
                | ((double(im(:,:,1))./double(im(:,:,2))>(r_pixel_rg_ratio_mean-r_pixel_rg_ratio_std))...
                & (double(im(:,:,1))./double(im(:,:,2))<(r_pixel_rg_ratio_mean+r_pixel_rg_ratio_std))...
                & (double(im(:,:,1))./double(im(:,:,3))>(r_pixel_rb_ratio_mean-r_pixel_rb_ratio_std))...
                & (double(im(:,:,3))./double(im(:,:,1))<(r_pixel_rb_ratio_mean+r_pixel_rb_ratio_std))...
                & (im(:,:,1)>(r_pixel_r_mean-r_pixel_r_std)) & (im(:,:,1)<(r_pixel_r_mean+r_pixel_r_std))...
                & (im(:,:,2)>(r_pixel_g_mean-r_pixel_g_std)) & (im(:,:,2)<(r_pixel_g_mean+r_pixel_g_std))...
                & (im(:,:,3)>(r_pixel_b_mean-r_pixel_b_std)) & (im(:,:,3)<(r_pixel_b_mean+r_pixel_b_std)));


        case 'CbCr'
            %Means and Standards deviations of red pixels from training signals in CbCr
            %space.
            b_pixel_Cb_mean=segmentation_values(23);
            b_pixel_Cb_std=segmentation_values(24)*stdr;
            b_pixel_Cr_mean=segmentation_values(25);
            b_pixel_Cr_std=segmentation_values(26)*stdr;

            r_pixel_Cb_mean=segmentation_values(29);
            r_pixel_Cb_std=segmentation_values(30)*stdr;
            r_pixel_Cr_mean=segmentation_values(31);
            r_pixel_Cr_std=segmentation_values(32)*stdr;

            
           im_YCbCr=rgb2ycbcr(im);
           im_seg= ((im_YCbCr(:,:,2)>(b_pixel_Cb_mean-b_pixel_Cb_std)) & (im_YCbCr(:,:,2)<(b_pixel_Cb_mean+b_pixel_Cb_std))...
                & (im_YCbCr(:,:,3)>(b_pixel_Cr_mean-b_pixel_Cr_std)) & (im_YCbCr(:,:,3)<(b_pixel_Cr_mean+b_pixel_Cr_std)))...
                | ((im_YCbCr(:,:,2)>(r_pixel_Cb_mean-r_pixel_Cb_std)) & (im_YCbCr(:,:,2)<(r_pixel_Cb_mean+r_pixel_Cb_std))...
                & (im_YCbCr(:,:,3)>(r_pixel_Cr_mean-r_pixel_Cr_std)) & (im_YCbCr(:,:,3)<(r_pixel_Cr_mean+r_pixel_Cr_std)));


        case 'H'
            %Means and Standards deviations of red pixels from training signals in H
            %space.
            b_pixel_H_mean=segmentation_values(21);
            b_pixel_H_std=segmentation_values(22)*stdr;
            r_pixel_H_mean=segmentation_values(27);
            r_pixel_H_std=segmentation_values(28)*stdr;
            
           im_HSV=rgb2hsv(im);
           im_seg= ((im_HSV(:,:,1)>(b_pixel_H_mean-b_pixel_H_std)) & (im_HSV(:,:,1)<(b_pixel_H_mean+b_pixel_H_std)))...
                | ((im_HSV(:,:,1)>(r_pixel_H_mean-r_pixel_H_std)) & (im_HSV(:,:,1)<1))...
                | (im_HSV(:,:,1)<(r_pixel_H_mean+r_pixel_H_std-1));
       case 'HS'
        % Red
        im_HSV=rgb2hsv(im);
        mask_RED = (im_HSV(:,:,1) > 0.9 | im_HSV(:,:,1) < 0.07) & im_HSV(:,:,2)>0.4 & im_HSV(:,:,3)>0;
        % Blue 1
        mask_BLUE1 = im_HSV(:,:,1) > 0.5 & im_HSV(:,:,1) < 0.7 & im_HSV(:,:,2)>0.4 & im_HSV(:,:,3)>0;
        % Blue 2
        mask_BLUE2 = im_HSV(:,:,1) > 0.58 & im_HSV(:,:,1) < 0.83 & im_HSV(:,:,2) > 0.15 & im_HSV(:,:,2) < 0.4 & im_HSV(:,:,3) < 0.3; 
        % Final
        im_seg = mask_BLUE1 | mask_RED | mask_BLUE2;
        
        case 'HS2'
            b_pixel_H_mean=segmentation_values(21);
            b_pixel_H_std=segmentation_values(22)*stdr;
            r_pixel_H_mean=segmentation_values(27);
            r_pixel_H_std=segmentation_values(28)*stdr;            
            b_pixel_S_mean=segmentation_values(33);
            b_pixel_S_std=segmentation_values(34)*stdr;
            r_pixel_S_mean=segmentation_values(35);
            r_pixel_S_std=segmentation_values(36)*stdr;
            
            im_HSV=rgb2hsv(im);    
           im_seg= ((im_HSV(:,:,1)>(b_pixel_H_mean-b_pixel_H_std)) & (im_HSV(:,:,1)<(b_pixel_H_mean+b_pixel_H_std))...
                & (im_HSV(:,:,2)>(b_pixel_S_mean-b_pixel_S_std)) & (im_HSV(:,:,2)<(b_pixel_S_mean+b_pixel_S_std)))...
                | ((((im_HSV(:,:,1)>(r_pixel_H_mean-r_pixel_H_std)) & (im_HSV(:,:,1)<1)) | (im_HSV(:,:,1)<(r_pixel_H_mean+r_pixel_H_std-1)))...
                &(im_HSV(:,:,2)>(r_pixel_S_mean-r_pixel_S_std)) & (im_HSV(:,:,2)<(r_pixel_S_mean+r_pixel_S_std)));
                

        case 'HSV' %method used by team5
           im_HSV=rgb2hsv(im);
            hu = im_HSV(:,:,1).*360;
            s = im_HSV(:,:,2);
            v = im_HSV(:,:,3);
             %Define Red and blue thresholds
             hred = [350 20];
             hblueA = [180 250];
             hblueB = [210 300];
             sred = 0.45;
             sblueA = 0.4;
             sblueB = [0.15 0.4];
             vred = 0;%0.25;
             vblueB = 0.3;

              red = ((((hu<hred(2))&(hu>=0))|((hu<=360)&(hu>hred(1))))&(s>sred)&(v>vred));
              blueA = ((hu<hblueA(2)) & (hu>hblueA(1)) & (s>sblueA));
              blueB = ((hu<hblueB(2)) & (hu>hblueB(1)) & (s>sblueB(1)) & (s<sblueB(2))) &(v<vblueB);

             %Create final mask
            im_seg = red |blueA|blueB;

        case 'HandCbCr'
            
            b_pixel_Cb_mean=segmentation_values(23);
            b_pixel_Cb_std=segmentation_values(24)*stdr;
            b_pixel_Cr_mean=segmentation_values(25);
            b_pixel_Cr_std=segmentation_values(26)*stdr;

            r_pixel_Cb_mean=segmentation_values(29);
            r_pixel_Cb_std=segmentation_values(30)*stdr;
            r_pixel_Cr_mean=segmentation_values(31);
            r_pixel_Cr_std=segmentation_values(32)*stdr;
            
            b_pixel_H_mean=segmentation_values(21);
            b_pixel_H_std=segmentation_values(22)*stdr;
            r_pixel_H_mean=segmentation_values(27);
            r_pixel_H_std=segmentation_values(28)*stdr;
            
           im_HSV=rgb2hsv(im);
           im_YCbCr=rgb2ycbcr(im);
           im_seg= (((im_HSV(:,:,1)>(b_pixel_H_mean-b_pixel_H_std)) & (im_HSV(:,:,1)<(b_pixel_H_mean+b_pixel_H_std)))...
                | ((im_HSV(:,:,1)>(r_pixel_H_mean-r_pixel_H_std)) & (im_HSV(:,:,1)<1))...
                | (im_HSV(:,:,1)<(r_pixel_H_mean+r_pixel_H_std-1)))...
                & (((im_YCbCr(:,:,2)>(b_pixel_Cb_mean-b_pixel_Cb_std)) & (im_YCbCr(:,:,2)<(b_pixel_Cb_mean+b_pixel_Cb_std))...
                & (im_YCbCr(:,:,3)>(b_pixel_Cr_mean-b_pixel_Cr_std)) & (im_YCbCr(:,:,3)<(b_pixel_Cr_mean+b_pixel_Cr_std)))...
                | ((im_YCbCr(:,:,2)>(r_pixel_Cb_mean-r_pixel_Cb_std)) & (im_YCbCr(:,:,2)<(r_pixel_Cb_mean+r_pixel_Cb_std))...
                & (im_YCbCr(:,:,3)>(r_pixel_Cr_mean-r_pixel_Cr_std)) & (im_YCbCr(:,:,3)<(r_pixel_Cr_mean+r_pixel_Cr_std))));

          
        case 'HorCbCr'
            b_pixel_Cb_mean=segmentation_values(23);
            b_pixel_Cb_std=segmentation_values(24)*stdr;
            b_pixel_Cr_mean=segmentation_values(25);
            b_pixel_Cr_std=segmentation_values(26)*stdr;

            r_pixel_Cb_mean=segmentation_values(29);
            r_pixel_Cb_std=segmentation_values(30)*stdr;
            r_pixel_Cr_mean=segmentation_values(31);
            r_pixel_Cr_std=segmentation_values(32)*stdr;
            
            b_pixel_H_mean=segmentation_values(21);
            b_pixel_H_std=segmentation_values(22)*stdr;
            r_pixel_H_mean=segmentation_values(27);
            r_pixel_H_std=segmentation_values(28)*stdr;
            
           im_HSV=rgb2hsv(im);
           im_YCbCr=rgb2ycbcr(im);
           im_seg= (((im_HSV(:,:,1)>(b_pixel_H_mean-b_pixel_H_std)) & (im_HSV(:,:,1)<(b_pixel_H_mean+b_pixel_H_std)))...
                | ((im_HSV(:,:,1)>(r_pixel_H_mean-r_pixel_H_std)) & (im_HSV(:,:,1)<1))...
                | (im_HSV(:,:,1)<(r_pixel_H_mean+r_pixel_H_std-1)))...
                | (((im_YCbCr(:,:,2)>(b_pixel_Cb_mean-b_pixel_Cb_std)) & (im_YCbCr(:,:,2)<(b_pixel_Cb_mean+b_pixel_Cb_std))...
                & (im_YCbCr(:,:,3)>(b_pixel_Cr_mean-b_pixel_Cr_std)) & (im_YCbCr(:,:,3)<(b_pixel_Cr_mean+b_pixel_Cr_std)))...
                | ((im_YCbCr(:,:,2)>(r_pixel_Cb_mean-r_pixel_Cb_std)) & (im_YCbCr(:,:,2)<(r_pixel_Cb_mean+r_pixel_Cb_std))...
                & (im_YCbCr(:,:,3)>(r_pixel_Cr_mean-r_pixel_Cr_std)) & (im_YCbCr(:,:,3)<(r_pixel_Cr_mean+r_pixel_Cr_std))));


        otherwise
            error('Incorrect color space defined');

    end



end
