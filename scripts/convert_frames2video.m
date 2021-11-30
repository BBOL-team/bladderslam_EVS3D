function convert_frames2video(folderpath,vid_name,frame_rate)
    temp = split(folderpath, '/');
    videopath = join(temp(1:end-2),'/');
    outputVideo = VideoWriter(fullfile(videopath{1},vid_name));
    outputVideo.FrameRate = frame_rate;
    open(outputVideo);
    imageNames = dir(fullfile(folderpath,'*.jpg'));
    imageNames = {imageNames.name}';
    for ii = 1:length(imageNames)
        img = imread(fullfile(folderpath,imageNames{ii}));
    %     img = imresize(img,2);
        writeVideo(outputVideo,img);
    end
    close(outputVideo);
end
