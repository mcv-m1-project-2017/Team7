
function system_evaluation(gt_path, detect_path, eval_file, performance_file)

    addpath('evaluation/');

    %Evaluation results file
    eval_file = fopen(eval_file, 'w');
    performance_file = fopen(performance_file, 'w');
    val_dataset = txt2cell('val_dataset.txt', 'columns', 1);
    %Evaluation per technique
    for tecnique=1:3
        evaluation = [];
        performance_eval = [];

        for i=1:size(val_dataset,1)
            file_id=val_dataset(i,1);
            gt = imread(strcat(gt_path, '/mask/mask.', file_id{1}, '.png'));
            mask = imread(strcat(detect_path,'/method', num2str(tecnique), '/mask/', file_id{1}, '.png'));
            detections = load(strcat(detect_path, '/method', num2str(tecnique), '/bboxes/', file_id{1},'.mat'));

            [pixelTP, pixelFP, pixelFN, pixelTN] = PerformanceAccumulationPixel(mask, gt);
            [pixelPrecision, pixelAccuracy, pixelSpecificity, pixelSensitivity] = ...
                PerformanceEvaluationPixel(pixelTP, pixelFP, pixelFN, pixelTN);

            evaluation = [evaluation; [pixelPrecision, pixelAccuracy, pixelSpecificity, pixelSensitivity, pixelTP, pixelFP, pixelFN]];
            
            bbox_gt = txt2cell(strcat(gt_path, '/gt/gt.', file_id{1},'.txt'), 'columns', 1:4);
        
            for k=1:size(bbox_gt,1)
               annotation(k).y = floor(str2num(cell2mat(bbox_gt(k,1))));
               annotation(k).x = floor(str2num(cell2mat(bbox_gt(k,2))));
               annotation(k).w = floor(str2num(cell2mat(bbox_gt(k,4)))) - floor(str2num(cell2mat(bbox_gt(k,2))))+1;
               annotation(k).h = floor(str2num(cell2mat(bbox_gt(k,3)))) - floor(str2num(cell2mat(bbox_gt(k,1))))+1; 
            end
            [TP,FN,FP] = PerformanceAccumulationWindow(detections.windowCandidates, annotation);
            [precision, sensitivity, accuracy] = PerformanceEvaluationWindow(TP, FN, FP);
            performance_eval = [performance_eval;[precision, accuracy, sensitivity, TP, FN, FP]];
        end

        tech_eval = mean(evaluation);
        perf_eval = mean(performance_eval);
        fprintf(eval_file, '%d\t%f\t%f\t%f\t%f\t%f\t%f\t%f\n', tecnique, tech_eval(1),tech_eval(2), ...
                tech_eval(3), tech_eval(4), tech_eval(5), tech_eval(6), tech_eval(7));
        fprintf(performance_file, '%d\t%f\t%f\t%f\t%f\t%f\t%f\n', tecnique, perf_eval(1),perf_eval(2), ...
                perf_eval(3), perf_eval(4), perf_eval(5), perf_eval(6));   
    end
    fclose(eval_file);
    fclose(performance_file);

end
