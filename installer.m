function varargout = installer(varargin)
% INSTALLER MATLAB code for installer.fig
%      INSTALLER, by itself, creates a new INSTALLER or raises the existing
%      singleton*.
%
%      H = INSTALLER returns the handle to a new INSTALLER or the handle to
%      the existing singleton*.
%
%      INSTALLER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in INSTALLER.M with the given input arguments.
%
%      INSTALLER('Property','Value',...) creates a new INSTALLER or raises
%      the existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before installer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to installer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help installer

% Last Modified by GUIDE v2.5 15-Feb-2015 14:02:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @installer_OpeningFcn, ...
                   'gui_OutputFcn',  @installer_OutputFcn, ...
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

% --- Executes just before installer is made visible.
function installer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to installer (see VARARGIN)

% Choose default command line output for installer
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

initialize_gui(hObject, handles, false);

% UIWAIT makes installer wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = installer_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --------------------------------------------------------------------
function initialize_gui(fig_handle, handles, isreset)
% If the metricdata field is present and the reset flag is false, it means
% we are we are just re-initializing a GUI by calling it from the cmd line
% while it is up. So, bail out as we dont want to reset the data.


% Update handles structure
guidata(handles.figure1, handles);


% --- Executes on button press in pushbutton_OK.
function pushbutton_OK_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_OK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
assignin('base', 'dataDirectory', [handles.edit_DataDirectory.String filesep]);
assignin('base', 'outputDirectory', [handles.edit_OutputDirectory.String filesep]);
assignin('base', 'jobManagerName', handles.listbox1.String{handles.listbox1.Value});
assignin('base', 'chosenDataset', handles.uibuttongroup2.SelectedObject.String);
delete(handles.output);

% --- Executes on button press in pushbutton_DataDirectory.
function pushbutton_DataDirectory_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_DataDirectory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dataDirectory = uigetdir(pwd, 'Please select data directory: ');
handles.edit_DataDirectory.String = fullfile(dataDirectory);


% --- Executes on button press in pushbutton_OutputDirectory.
function pushbutton_OutputDirectory_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_OutputDirectory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
outputDirectory = uigetdir(pwd, 'Please select output directory: ');
handles.edit_OutputDirectory.String = fullfile(outputDirectory);


function edit_DataDirectory_Callback(hObject, eventdata, handles)
% hObject    handle to edit_DataDirectory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_DataDirectory as text
%        str2double(get(hObject,'String')) returns contents of edit_DataDirectory as a double


% --- Executes during object creation, after setting all properties.
function edit_DataDirectory_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_DataDirectory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_OutputDirectory_Callback(hObject, eventdata, handles)
% hObject    handle to edit_OutputDirectory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_OutputDirectory as text
%        str2double(get(hObject,'String')) returns contents of edit_OutputDirectory as a double


% --- Executes during object creation, after setting all properties.
function edit_OutputDirectory_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_OutputDirectory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
jms = parallel.clusterProfiles;
hObject.String = jms;
