[file, path] = uigetfile('.csv', 'Select CellProfiler trajectory outfile file');

cpData = ReadCellProfilerTrajectory(fullfile(path, file));

nRows = height(cpData);

cellCount = 1;

idMap = containers.Map;

scaleValue = power(2,16)-1;

for row = 1 : nRows
    imageNo = cpData.ImageNumber(row);
    if(imageNo > 1)
        lifetime = cpData.TrackObjects_Lifetime_50(row);
        id = cpData.TrackObjects_Label_50(row);
        if(lifetime < 2)
            idMap(num2str(id)) = cellCount;
            cellCount = cellCount + 1;
        end
        if(isKey(idMap, num2str(id)))
            index = idMap(num2str(id));
            intens = cpData.Intensity_MeanIntensity_GFP(row) * scaleValue;
            concatNucData(lifetime, index) = intens;
        end
    end
end

csvwrite(fullfile(path, 'concatenated_nuc_intensities.csv'),concatNucData);