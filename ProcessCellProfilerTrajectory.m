function ProcessCellProfilerTrajectory()
%PROCESSCELLPROFILERTRAJECTORY Aligns trajectory data from CellProfiler
%tracking
%When prompted, select a CSV file containing data on tracked objects
%produced using CellProfiler for the purposes of analysing changes in intensity
%localisation within cells. The function expects to find columns
%pertaining to TrackObjects_Lifetime, TrackObjects_Label and
%Intensity_MeanIntensity

    [file, path] = uigetfile('.csv', 'Select CellProfiler trajectory outfile file');
    fprintf('Reading file %s\n', file);
    cpData = ReadCellProfilerTrajectory(fullfile(path, file));
    nRows = height(cpData);
    fprintf('%d rows of data\n', nRows);
    cellCount = 1;
    idMap = containers.Map;
    scaleValue = power(2,16)-1;
    fprintf('Processing...\n');
    for row = 1 : nRows
        imageNo = cpData.ImageNumber(row);
        if(imageNo > 1)
            lifetime = cpData.TrackObjects_Lifetime_50(row);
            id = num2str(cpData.TrackObjects_Label_50(row));
            if(lifetime < 2 && ~strcmpi(id, 'nan'))
                idMap(id) = cellCount;
                cellCount = cellCount + 1;
            end
            if(isKey(idMap, id))
                index = idMap(id);
                concatNucData(lifetime, index) = cpData.Intensity_MeanIntensity_GFP(row) * scaleValue;
                concatCytoData(lifetime, index) = cpData.Intensity_MeanIntensity_GFP1(row) * scaleValue;
            end
        end
    end
    fprintf('Saving outputs...\n');
    csvwrite(fullfile(path, 'concatenated_nuc_intensities.csv'),concatNucData);
    csvwrite(fullfile(path, 'concatenated_cyto_intensities.csv'),concatCytoData);
    fprintf('Done.\n');
end

