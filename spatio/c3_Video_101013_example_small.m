clear; close all;clc

cll_FolerPath = {'EALT','AMP','TIM','PID','HFA','HFO'};
s_numFol = numel(cll_FolerPath);

stru_Files = dir(fullfile(cll_FolerPath{1}, '*.png')); 
s_numImaFolder = numel(stru_Files);

str_VidName = 'Example_Concu.mp4';
s_fps = 6; 
videoObj = VideoWriter(str_VidName, 'MPEG-4');
videoObj.FrameRate = s_fps;
open(videoObj);

h = waitbar(0, 'Creating video...');
for s_Frame = 1:s_numImaFolder

    m_CurrentFrame = [];
    m_FrameUp = [];
    m_FrameDown = [];
        
    for s_Fol = 1:s_numFol/2
        str_PathImg = fullfile(cll_FolerPath{s_Fol},...
            [num2str(s_Frame) '_' cll_FolerPath{s_Fol} '.png']);
        m_Image = imread(str_PathImg);        
        m_FrameUp = [m_FrameUp, m_Image];
    end

    for s_Fol = (s_numFol/2)+1:s_numFol
        str_PathImg = fullfile(cll_FolerPath{s_Fol},...
            [num2str(s_Frame) '_' cll_FolerPath{s_Fol} '.png']);
        m_Image = imread(str_PathImg);        
        m_FrameDown = [m_FrameDown, m_Image];
    end

    m_CurrentFrame = [m_FrameUp;m_FrameDown];

    writeVideo(videoObj, m_CurrentFrame);
    waitbar(s_Frame/ s_numImaFolder, h, sprintf('Frame %d of %d', s_Frame,...
        s_numImaFolder));
end

% Close video
close(videoObj);
close(h)