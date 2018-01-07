function Posture_Analysis
%Posture_Analysis.m measures the user's posture while sitting and using their
%computer and alerts the user when their posture is sub optimal
%Program uses laptops/computers webcam to take an initial snapshot and use
%rudimentary motion tracking programming to follow changes in pixel
%distance ratios between the head and shoulders
%Program takes an initial snapshot for later compariosn, so user must start
%in ideal posture for later comparison

%User must have entire head and curvature of shoulders within view of the
%webcam for optimal use

%Visible and audible indication for user if poor posture
%occurs

%Program requires monochromatic,homogenous background behind user for
%accurate tracking of user's posture

%Requires MATLAB R2017a or better and MATLAB Support Package for USB Webcams
clear
close all
clc

f.cam=webcam;
%hides figure until set up
f.fig=figure('Visible','off','Color','white','Position',[360,500,600,600]);
set(f.fig,'Name','Posture Analysis')
movegui(f.fig,'center')

f.hbutton1=uicontrol('Style','pushbutton','String','Start Program','Position',[250,275,100,50]);
f.hbutton2=uicontrol('Style','pushbutton','String','Exit Program','Position',[250,175,100,50]);
f.hstr=uicontrol('Style','text','BackgroundColor','white','Position',[150,325,300,75],'String','Sit up straight and start program','ForegroundColor','Black','Fontsize',12);

set(f.fig,'Visible','on')
%User must be in ideal posture before using button 1
set(f.hbutton1,'Callback',{@callbackfunc1,f})
%Button 2 exits gui at any time
set(f.hbutton2,'Callback',{@callbackfunc2,f})

    function callbackfunc1(hObject,eventdata,f)
        %callback function is called by the callback property in first push button
        set([f.hbutton1,f.hstr],'Visible','off')
        f.hstr2=uicontrol('Style','text','BackgroundColor','white','Position',[150,250,300,75],'String','Program is running','ForegroundColor','Black','Fontsize',12);
        
        initial_new_B=cell(0);
        %Allows user to get set
        pause(2)
        f.initial_image=snapshot(f.cam);
        %Adjusts RGB values for grayscale conversion
        iI=.2989*f.initial_image(:,:,1)+.5870*f.initial_image(:,:,2)+.1140*f.initial_image(:,:,3);
        binary_initial_image=imbinarize(iI,'adaptive');
        [iB,~,~]=bwboundaries(binary_initial_image);
        
        for i=1:length(iB)
            %filters border size assuming user profile is largest border
            %detected
            if size(iB{i},1)>1500
                initial_new_B=[initial_new_B;iB{i}];
            end
        end
        %Removes "halo" left in images by shadows to track head and shoulders
        ioutline_data_initial=initial_new_B{1};
        ioutline_data_final=ones(length(ioutline_data_initial),2);
        ihead_loc=ones(length(ioutline_data_initial),2);
        for ii=min(ioutline_data_initial(:,2)):max(ioutline_data_initial(:,2))
            ioutline_data_final(ii,1)=ii;
            ioutline_data_final(ii,2)=max(ioutline_data_initial(:,1).*(ioutline_data_initial(:,2)==ii));
            ihead_loc(ii,1)=ii;
            iintermediate=(ioutline_data_initial(:,1).*(ioutline_data_initial(:,2)==ii));
            iintermediate(iintermediate<=0)=inf;
            ihead_loc(ii,2)=min(iintermediate);
        end
        
        ioutline_data_final=ioutline_data_final(min(ioutline_data_initial(:,2)):max(ioutline_data_initial(:,2)),1:2);
        ihead_loc=ihead_loc(floor(length(ioutline_data_final)/3):floor(length(ioutline_data_final)-length(ioutline_data_final)/3),1:2);
        ishoulder_one=ioutline_data_final(1:floor(length(ioutline_data_final)/3),1:2);
        ishoulder_two=ioutline_data_final(floor(length(ioutline_data_final)-length(ioutline_data_final)/3):length(ioutline_data_final),1:2);
        %creates qudratic best fit lines of user profile
        icoeff_h=polyfit(ihead_loc(:,1),ihead_loc(:,2),2);
        icoeff_s1=polyfit(ishoulder_one(:,1),ishoulder_one(:,2),2);
        icoeff_s2=polyfit(ishoulder_two(:,1),ishoulder_two(:,2),2);
        
        ipt_h(1)=floor(-icoeff_h(2)/(2*icoeff_h(1)));
        ipt_h(2)=polyval(icoeff_h,ipt_h(1));
        ipt_one(1)=floor(-icoeff_s1(2)/(2*icoeff_s1(1)));
        ipt_one(2)=polyval(icoeff_s1,ipt_one(1));
        ipt_two(2)=floor(-icoeff_s2(2)/(2*icoeff_s2(1)));
        ipt_two(1)=ipt_two(2);
        ipt_two(2)=polyval(icoeff_s2,ipt_two(1));
        %determines baseline distances between head and shoulders
        initial_pixel_diff_shoulder=sqrt((ipt_two(1)-ipt_one(1))^2+(ipt_two(2)-ipt_one(2))^2);
        initial_s1h=sqrt((ipt_h(1)-ipt_one(1))^2+(ipt_h(2)-ipt_one(2))^2);
        initial_s2h=sqrt((ipt_two(1)-ipt_h(1))^2+(ipt_two(2)-ipt_h(2))^2);
        global done
        done=1;
        while done==1
            drawnow()
            new_B=cell(0);
            %optional pause for new snapshot
            %pause(2)
            new_image=snapshot(f.cam);
            %Adjust for grayscale conversion
            I=.2989*new_image(:,:,1)+.5870*new_image(:,:,2)+.1140*new_image(:,:,3);
            binary_image=imbinarize(I,'adaptive');
            [B,~,~]=bwboundaries(binary_image);
            
            for i=1:length(B)
                if size(B{i},1)>1500
                    new_B=[new_B;B{i}];
                end
            end
            %removes "halo" of shadow effect
            outline_data_initial=new_B{1};
            outline_data_final=ones(length(outline_data_initial),2);
            head_loc=ones(length(outline_data_initial),2);
            for ii=min(outline_data_initial(:,2)):max(outline_data_initial(:,2))
                outline_data_final(ii,1)=ii;
                outline_data_final(ii,2)=max(outline_data_initial(:,1).*(outline_data_initial(:,2)==ii));
                head_loc(ii,1)=ii;
                intermediate=(outline_data_initial(:,1).*(outline_data_initial(:,2)==ii));
                intermediate(intermediate<=0)=inf;
                head_loc(ii,2)=min(intermediate);
            end
            
            outline_data_final=outline_data_final(min(outline_data_initial(:,2))+1:max(outline_data_initial(:,2))-1,1:2);
            head_loc=head_loc(floor(length(outline_data_final)/3):floor(length(outline_data_final)-length(outline_data_final)/3),1:2);
            shoulder_one=outline_data_final(1:floor(length(outline_data_final)/3),1:2);
            shoulder_two=outline_data_final(floor(length(outline_data_final)-length(outline_data_final)/3):length(outline_data_final),1:2);
            %finds best fit quadratic function
            coeff_h=polyfit(head_loc(:,1),head_loc(:,2),2);
            coeff_s1=polyfit(shoulder_one(:,1),shoulder_one(:,2),2);
            coeff_s2=polyfit(shoulder_two(:,1),shoulder_two(:,2),2);
            
            pt_h(1)=floor(-coeff_h(2)/(2*coeff_h(1)));
            pt_h(2)=polyval(coeff_h,pt_h(1));
            pt_one(1)=floor(-coeff_s1(2)/(2*coeff_s1(1)));
            pt_one(2)=polyval(coeff_s1,pt_one(1));
            pt_two(2)=floor(-coeff_s2(2)/(2*coeff_s2(1)));
            pt_two(1)=pt_two(2);
            pt_two(2)=polyval(coeff_s2,pt_two(1));
            %finds new iteration of head and shoulder distances
            pixel_diff_shoulder=sqrt((pt_two(1)-pt_one(1))^2+(pt_two(2)-pt_one(2))^2);
            s1h=sqrt((pt_h(1)-pt_one(1))^2+(pt_h(2)-pt_one(2))^2);
            s2h=sqrt((pt_two(1)-pt_h(1))^2+(pt_two(2)-pt_h(2))^2);
            %Determines percentage differences
            s_comp=abs(pixel_diff_shoulder/initial_pixel_diff_shoulder-1);
            s1h_comp=abs(s1h/initial_s1h-1);
            s2h_comp=abs(s2h/initial_s2h-1);
            %Uses 20% difference threshold
            if s_comp>.2 || s1h_comp>.2 || s2h_comp>.2
                f.slouch_image=new_image;
                %Visible and audible indication for user if poor posture
                %occurs
                f.hstr2=uicontrol('Style','text','BackgroundColor','white','Position',[150,250,300,75],'String','Sit Up! Fix that Posture!','ForegroundColor','Black','Fontsize',12);
                for h=1:3
                    beep
                    pause(1)
                end
            else
                %Some encouragement to get back on track
                f.hstr2=uicontrol('Style','text','BackgroundColor','white','Position',[150,250,300,75],'String','Looking Good! Keep it Up!','ForegroundColor','Black','Fontsize',12);
            end
        end
    end
%Closes GUI and program
    function callbackfunc2(hObject,eventdata,f)
        global done
        done=0;
        close all
        clc
        clear
    end
end