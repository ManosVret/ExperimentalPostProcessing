function [dataOut] = ReadFile_TDMS(Data_Path)
% This function is based on the ReadFile.m script downloaded from 
% http://www.ni.com/example/30957/en/. It takes a .tdms file specified in
% the input "Data_Path", reads the data, and saves it in "dataOut". This
% variable is a cell array, with each element corresponding to a channel 
% group of  the tdms file. Each element contains a 2D array, where each
% column is a channel of the group.
%
%%%     Reynard de Vries    %%%
%%%         TU Delft        %%%
%%% Last modified: 23-02-19 %%%

% Input libraries
NI_TDM_DLL_Path = '.\dev\bin\64-bit\nilibddc.dll';
NI_TDM_H_Path = '.\dev\include\64-bit\nilibddc_m.h';
libname=strtok('nilibddc.dll','.');

%Recreate needed property constants defined in nilibddc_m.h
DDC_FILE_NAME					=	'name';
DDC_FILE_DESCRIPTION			=	'description';
DDC_FILE_TITLE					=	'title';
DDC_FILE_AUTHOR					=	'author';
DDC_FILE_DATETIME				=	'datetime';
DDC_CHANNELGROUP_NAME			=	'name';
DDC_CHANNELGROUP_DESCRIPTION	=	'description';
DDC_CHANNEL_NAME				=	'name';

%Load nilibddc.dll (Always call 'unloadlibrary(libname)' after finished using the library)
loadlibrary(NI_TDM_DLL_Path,NI_TDM_H_Path);

%Open the file (Always call 'DDC_CloseFile' when you are finished using a file)
fileIn = 0;
[~,~,~,file]=calllib(libname,'DDC_OpenFileEx',Data_Path,'',1,fileIn);

%Read and display file name property
filenamelenIn = 0;

%Get the length of the 'DDC_FILE_NAME' string property
[err,~,filenamelen]=calllib(libname,'DDC_GetFileStringPropertyLength',file,DDC_FILE_NAME,filenamelenIn);
if err==0 %Only proceed if the property is found
    %Initialize a string to the length of the property value
    pfilename=libpointer('stringPtr',blanks(filenamelen));
    [~,~,filename]=calllib(libname,'DDC_GetFileProperty',file,DDC_FILE_NAME,pfilename,filenamelen+1);
    setdatatype(filename,'int8Ptr',1,filenamelen);
end

%Read and display file description property
filedesclenIn = 0;
%Get the length of the 'DDC_FILE_DESCRIPTION' string property
[err,~,filedesclen]=calllib(libname,'DDC_GetFileStringPropertyLength',file,DDC_FILE_DESCRIPTION,filedesclenIn);
if err==0 %Only proceed if the property is found
    %Initialize a string to the length of the property value
    pfiledesc=libpointer('stringPtr',blanks(filedesclen));
    [~,~,filedesc]=calllib(libname,'DDC_GetFileProperty',file,DDC_FILE_DESCRIPTION,pfiledesc,filedesclen+1);
    setdatatype(filedesc,'int8Ptr',1,filedesclen);
end

%Read and display file title property
filetitlelenIn = 0;
%Get the length of the 'DDC_FILE_TITLE' string property
[err,~,filetitlelen]=calllib(libname,'DDC_GetFileStringPropertyLength',file,DDC_FILE_TITLE,filetitlelenIn);
if err==0 %Only proceed if the property is found
    %Initialize a string to the length of the property value
    pfiletitle=libpointer('stringPtr',blanks(filetitlelen));
    [~,~,filetitle]=calllib(libname,'DDC_GetFileProperty',file,DDC_FILE_TITLE,pfiletitle,filetitlelen+1);
    setdatatype(filetitle,'int8Ptr',1,filetitlelen);
end

%Read and display file author property
fileauthlenIn = 0;
%Get the length of the 'DDC_FILE_AUTHOR' string property
[err,~,fileauthlen]=calllib(libname,'DDC_GetFileStringPropertyLength',file,DDC_FILE_AUTHOR,fileauthlenIn);
if err==0 %Only proceed if the property is found
    %Initialize a string to the length of the property value
    pfileauth=libpointer('stringPtr',blanks(fileauthlen));
    [~,~,fileauth]=calllib(libname,'DDC_GetFileProperty',file,DDC_FILE_AUTHOR,pfileauth,fileauthlen+1);
    setdatatype(fileauth,'int8Ptr',1,fileauthlen);
end

%Read and display file timestamp property
yearIn = 0;
monthIn = 0;
dayIn = 0;
hourIn = 0;
minuteIn = 0;
secondIn = 0;
msecondIn = 0;
wkdayIn = 0;
[err,~,year,month,day,hour,minute,second,msecond,~]=calllib(libname,'DDC_GetFilePropertyTimestampComponents',file,DDC_FILE_DATETIME,yearIn,monthIn,dayIn,hourIn,minuteIn,secondIn,msecondIn,wkdayIn);
if err==0 %Only proceed if the property is found
    disp(['File Timestamp: ' num2str(month) '/' num2str(day) '/' num2str(year) ', ' num2str(hour) ':' num2str(minute) ':' num2str(second) ':' num2str(msecond)]);
end

%Get channel groups
%Get the number of channel groups
numgrpsIn = 0;
[~,numgrps]=calllib(libname,'DDC_GetNumChannelGroups',file,numgrpsIn);
%Get channel groups only if the number of channel groups is greater than zero
if numgrps>0
	%Initialize an array to hold the desired number of groups
    pgrps=libpointer('int64Ptr',zeros(1,numgrps));
    [~,grps]=calllib(libname,'DDC_GetChannelGroups',file,pgrps,numgrps);
end    
for i=1:numgrps %For each channel group
    %Get channel group name property
    grpnamelenIn = 0;
    [err,~,grpnamelen]=calllib(libname,'DDC_GetChannelGroupStringPropertyLength',grps(i),DDC_CHANNELGROUP_NAME,grpnamelenIn);
    if err==0 %Only proceed if the property is found
		%Initialize a string to the length of the property value
        pgrpname=libpointer('stringPtr',blanks(grpnamelen));
        [~,~,grpname]=calllib(libname,'DDC_GetChannelGroupProperty',grps(i),DDC_CHANNELGROUP_NAME,pgrpname,grpnamelen+1);
        setdatatype(grpname,'int8Ptr',1,grpnamelen);
    else
        grpname=libpointer('stringPtr','');
    end
        
    %Get channel group description property
    grpdesclenIn = 0;
    [err,~,grpdesclen]=calllib(libname,'DDC_GetChannelGroupStringPropertyLength',grps(i),DDC_CHANNELGROUP_DESCRIPTION,grpdesclenIn);
    if err==0 %Only proceed if the property is found
		%Initialize a string to the length of the property value
        pgrpdesc=libpointer('stringPtr',blanks(grpdesclen));
        [~,~,~]=calllib(libname,'DDC_GetChannelGroupProperty',grps(i),DDC_CHANNELGROUP_DESCRIPTION,pgrpdesc,grpdesclen+1);
    end
    
    %Get channels
    numchansIn = 0;
    %Get the number of channels in this channel group
    [~,numchans]=calllib(libname,'DDC_GetNumChannels',grps(i),numchansIn);
    %Get channels only if the number of channels is greater than zero
    if numchans>0
		%Initialize an array to hold the desired number of channels
        pchans=libpointer('int64Ptr',zeros(1,numchans));
        [~,chans]=calllib(libname,'DDC_GetChannels',grps(i),pchans,numchans);
    end
    
    channames=cell(1,numchans);
    
    for j=1:numchans %For each channel in the channel group
        %Get channel name property
        channamelenIn = 0;
        [err,~,channamelen]=calllib(libname,'DDC_GetChannelStringPropertyLength',chans(j),DDC_CHANNEL_NAME,channamelenIn);
        if err==0 %Only proceed if the property is found
			%Initialize a string to the length of the property value
            pchanname=libpointer('stringPtr',blanks(channamelen));
            [~,~,channame]=calllib(libname,'DDC_GetChannelProperty',chans(j),DDC_CHANNEL_NAME,pchanname,channamelen+1);
            setdatatype(channame,'int8Ptr',1,channamelen);
            channames{j}=char(channame.Value);
        else
            channames{j}='';
        end
        
        %Get channel data type
        typeIn = 0;
        [~,type]=calllib(libname,'DDC_GetDataType',chans(j),typeIn);
        
        %Get channel values if data type of channel is double (DDC_Double = 10)
        if strcmp(type,'DDC_Double')
            numvalsIn = 0;
            [~,numvals]=calllib(libname,'DDC_GetNumDataValues',chans(j),numvalsIn);
			%Initialize an array to hold the desired number of values
            pvals=libpointer('doublePtr',zeros(1,numvals));
            [~,vals]=calllib(libname,'DDC_GetDataValues',chans(j),0,numvals,pvals);
            setdatatype(vals,'doublePtr',1,numvals);
            
            %Add channel values to a matrix. The comment, #ok<AGROW>, at
            %the end of the line prevents warnings about the matrix needing 
            %to allocate more memory for the added values.
            chanvals(:,j)=(vals.Value); %#ok<AGROW>
        end
            
    end
    
    %Plot Data from channels in this group
    dataOut{i} = chanvals;
    clear chanvals;
end

%Close file
err = calllib(libname,'DDC_CloseFile',file);

%Unload nilibddc.dll
unloadlibrary(libname);