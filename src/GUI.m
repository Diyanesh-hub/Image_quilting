function varargout = GUI(varargin)
% GUI MATLAB code for GUI.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI.M with the given input arguments.
%
%      GUI('Property','Value',...) creates a new GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI

% Last Modified by GUIDE v2.5 22-Apr-2023 12:01:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before GUI is made visible.
function GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI (see VARARGIN)

% Choose default command line output for GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function setGlobalA(val)
    global A
    A = val;

function a = getGlobalA
    global A
    a = A;

function setGlobalB(val)
    global B
    B = val;

function b = getGlobalB
    global B
    b = B;

function setGlobalC(val)
    global C
    C = val;

function c = getGlobalC
    global C
    c = C;    
% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
    [filename pathname]=uigetfile("*.*");
    a=imread(strcat(pathname,filename));
    axes(handles.axes1);
    imshow(a);
    setGlobalA(a);

% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
    [filename pathname]=uigetfile("*.*");
    b=imread(strcat(pathname,filename));
    axes(handles.axes2);
    imshow(b);
    setGlobalB(b);
    
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
    a = im2double(getGlobalA);
    b = im2double(getGlobalB);
    if(length(size(a)) ~= 3)
        a = repmat(a,[1 1 3]);
    end
    
    if(length(size(b)) ~= 3)
        b = repmat(b,[1 1 3]);
    end
    
    inputTexture = rgb2gray(a);
    inputTarget = rgb2gray(b);
    
    mask_in = inputTexture<-1;
    mask_out = inputTarget<-1;
    
    inputTexture(mask_in) = -1;
    inputTarget(mask_out) = -1;
    
    [m,n] = size(inputTarget);
    
    w = 8; al = 0.43;
    o = round(w/3);
    m1 = floor((m-o)/w)*w+o;
    n1 = floor((n-o)/w)*w+o;
    outputTexture = zeros(m,n);
    outputTexture1 = zeros(m,n,3);
    
    iter = 2;
    
    for p = 1:iter
        for i = [1:floor(m1/w),(m-o)/w]
            for j = [1:floor(n1/w),(n-o)/w]
                if (all(all(mask_out((i-1)*w+1:i*w+o,(j-1)*w+1:j*w+o))))
                    outputTexture((i-1)*w+1:i*w+o,(j-1)*w+1:j*w+o)=0;
                    outputTexture1((i-1)*w+1:i*w+o,(j-1)*w+1:j*w+o,:)=0;
                    continue;
                end
                mask = zeros(w+o,w+o);
                temp1 = outputTexture((i-1)*w+1:i*w+o,(j-1)*w+1:j*w+o); 
    
                if(i==1 && j ==1)
                    [nearPatch,nearPatch1] = givePatch1(al,a,inputTexture(1:w+o,1:w+o),inputTarget(1:w+o,1:w+o),temp1,mask);
                    outputTexture(1:w+o,1:w+o) = nearPatch;
                    outputTexture1(1:w+o,1:w+o,:) = nearPatch1;
                    continue;
    
                elseif(i==1)
                    mask(:,1:o) = 1;
                    [nearPatch,nearPatch1] = givePatch1(al,a,inputTexture,inputTarget((i-1)*w+1:i*w+o,(j-1)*w+1:j*w+o),temp1,mask);
    
                    error = (nearPatch.*mask-temp1.*mask).^2;
                    error = error(:,1:o);
                    [cost,path] = findBoundaryHelper1(error);
                    boundary = zeros(w+o,w+o);
                    [~,ind] = min(cost(1,:));
                    boundary(:,1:o) = findBoundaryHelper2(path,ind);
    
                elseif(j==1)
                    mask(1:o,:) = 1;
                    [nearPatch,nearPatch1] = givePatch1(al,a,inputTexture,inputTarget((i-1)*w+1:i*w+o,(j-1)*w+1:j*w+o),temp1,mask);
    
                    error = (nearPatch.*mask-temp1.*mask).^2;
                    error = error(1:o,:);
                    [cost,path] = findBoundaryHelper1(error');
                    boundary = zeros(w+o,w+o);
                    [~,ind] = min(cost(1,:));
                    boundary(1:o,:) = (findBoundaryHelper2(path,ind))';
    
                else
                    mask(:,1:o) = 1;
                    mask(1:o,:) = 1;
    
                    [nearPatch,nearPatch1] = givePatch1(al,a,inputTexture,inputTarget((i-1)*w+1:i*w+o,(j-1)*w+1:j*w+o),temp1,mask);
    
                    error = (nearPatch.*mask-temp1.*mask).^2;
                    error1 = error(1:o,:);
                    [cost1,path1] = findBoundaryHelper1(error1');
    
                    error2 = error(:,1:o);
                    [cost2,path2] = findBoundaryHelper1(error2);
    
                    cost = cost1(1:o,:)+cost2(1:o,:);
    
                    boundary = zeros(w+o,w+o);
                    [~,ind] = min(diag(cost));
                    boundary(1:o,ind:w+o) = (findBoundaryHelper2(path1(ind:o+w,:),o-ind+1))';
    
                    boundary(ind:o+w,1:o) = findBoundaryHelper2(path2(ind:o+w,:),ind);
    
                    boundary(1:ind-1,1:ind-1) = 1;
    
                end
    
                smoothBoundary = imgaussfilt(boundary,1.5 );
                smoothBoundary1 = repmat(boundary,[1 1 3]);
                temp2 = temp1.*(smoothBoundary) + nearPatch.*(1-smoothBoundary);
                outputTexture((i-1)*w+1:i*w+o,(j-1)*w+1:j*w+o) = temp2;
                outputTexture1((i-1)*w+1:i*w+o,(j-1)*w+1:j*w+o,:) = outputTexture1((i-1)*w+1:i*w+o,(j-1)*w+1:j*w+o,:).*(smoothBoundary1)+nearPatch1.*(1-smoothBoundary1);
            end
        end
        
        output = outputTexture1(1:m,1:n,:);
        output(repmat(mask_out,[1 1 3]))=0;
        
     
        w = round(w*0.7);
        o = round(w/3);
        if(iter > 1)
            al = 0.8*(p-1)/(iter-1)+0.1;
        else
            continue;
        end
        
        inputTarget = outputTexture;
        inputTexture(mask_in)=-1;
        inputTarget(mask_out)=-1;
        
        [m,n] = size(inputTarget);
        m1 = floor((m-o)/w)*w+o;
        n1 = floor((n-o)/w)*w+o;
        
        outputTexture = zeros(m,n);
        outputTexture1 = zeros(m,n,3);
    end
    axes(handles.axes3);
    imshow(output); truesize;
    
    % hObject    handle to pushbutton3 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    
    % --- Executes on button press in pushbutton4.
    function pushbutton4_Callback(hObject, eventdata, handles)
    [filename pathname]=uigetfile("*.*");
    c=imread(strcat(pathname,filename));
    axes(handles.axes4);
    imshow(c);
    setGlobalC(c);
    % hObject    handle to pushbutton4 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    
    % --- Executes on button press in pushbutton5.
    function pushbutton5_Callback(hObject, eventdata, handles)
     
    a = im2double(getGlobalC);
    if(length(size(a)) ~= 3)
        a = repmat(a,[1 1 3]);
    end
    inputTexture = rgb2gray(a);
    [m,n] = size(inputTexture);
    
    magnification = 2;
    w = 50;
    o = round(w/3);
    m1 = ceil(m*magnification/w)*w+o;
    n1 = ceil(n*magnification/w)*w+o;
    outputTexture = zeros(m1,n1);
    outputTexture1 = zeros(m1,n1,3);
    
    
    for i = 1:floor(m1/w)
        for j = 1:floor(n1/w)
            mask = zeros(w+o,w+o);
            temp1 = outputTexture((i-1)*w+1:i*w+o,(j-1)*w+1:j*w+o); 
    
            if(i==1 && j ==1)
                outputTexture(1:w+o,1:w+o) = inputTexture(1:w+o,1:w+o);
                outputTexture1(1:w+o,1:w+o,:) = a(1:w+o,1:w+o,:);
                continue;
    
            elseif(i==1)
                mask(:,1:o) = 1;
                
                [nearPatch,nearPatch1] = givePatch(a,inputTexture,temp1,mask);
                
                error = (nearPatch.*mask-temp1.*mask).^2;
                error = error(:,1:o);
                [cost,path] = findBoundaryHelper1(error);
                boundary = zeros(w+o,w+o);
                [~,ind] = min(cost(1,:));
                boundary(:,1:o) = findBoundaryHelper2(path,ind);
    
            elseif(j==1)
                mask(1:o,:) = 1;
                
                [nearPatch,nearPatch1] = givePatch(a,inputTexture,temp1,mask);
                
                error = (nearPatch.*mask-temp1.*mask).^2;
                error = error(1:o,:);
                [cost,path] = findBoundaryHelper1(error');
                boundary = zeros(w+o,w+o);
                [~,ind] = min(cost(1,:));
                boundary(1:o,:) = (findBoundaryHelper2(path,ind))';
                
            else
                mask(:,1:o) = 1;
                mask(1:o,:) = 1;
                
                [nearPatch,nearPatch1] = givePatch(a,inputTexture,temp1,mask);
                
                error = (nearPatch.*mask-temp1.*mask).^2;
                error1 = error(1:o,:);
                [cost1,path1] = findBoundaryHelper1(error1');
                
                error2 = error(:,1:o);
                [cost2,path2] = findBoundaryHelper1(error2);
                
                cost = cost1(1:o,:)+cost2(1:o,:);
                
                boundary = zeros(w+o,w+o);
                [~,ind] = min(diag(cost));
                boundary(1:o,ind:w+o) = (findBoundaryHelper2(path1(ind:o+w,:),o-ind+1))';
                
                boundary(ind:o+w,1:o) = findBoundaryHelper2(path2(ind:o+w,:),ind);
                
                boundary(1:ind-1,1:ind-1) = 1;
            end
          
            smoothBoundary = boundary;
            smoothBoundary1 = repmat(boundary,[1 1 3]);%
            temp2 = temp1.*(smoothBoundary) + nearPatch.*(1-smoothBoundary);
            outputTexture((i-1)*w+1:i*w+o,(j-1)*w+1:j*w+o) = temp2;
            outputTexture1((i-1)*w+1:i*w+o,(j-1)*w+1:j*w+o,:) = outputTexture1((i-1)*w+1:i*w+o,(j-1)*w+1:j*w+o,:).*(smoothBoundary1)+nearPatch1.*(1-smoothBoundary1);
        end
    end
    output = outputTexture1(1:m1-o,1:n1-o,:);
    axes(handles.axes5);
    imshow(output);truesize;
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
