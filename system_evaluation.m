%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% SYSTEM EVALUATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function system_evaluation(directory)

    addpath('evaluation/');

    %Evaluation results file
    eval_file = fopen('eval_results.txt', 'w');
    val_dataset = textscan(fopen('val_dataset.txt','rt'),'%s');

    %Evaluation per technique
    for technique=1:3
        evaluation = [];

        for i=1:size(val_dataset{1},1)
            file_id=val_dataset{1}(i);
            gt = imread(strcat(directory, '/mask/mask.', file_id{1}, '.png'));
            mask = imread(strcat('candidate_mask/mask.0',num2str(technique),'.', file_id{1}, '.png'));

            [pixelTP, pixelFP, pixelFN, pixelTN] = PerformanceAccumulationPixel(mask, gt);
            [pixelPrecision, pixelAccuracy, pixelSpecificity, pixelSensitivity] = ...
                PerformanceEvaluationPixel(pixelTP, pixelFP, pixelFN, pixelTN);

            evaluation = [evaluation; [pixelPrecision, pixelAccuracy, pixelSpecificity, pixelSensitivity]];
        end

        tech_eval = mean(evaluation);
        fprintf(eval_file, '%d\t%f\t%f\t%f\t%f\n', technique, tech_eval(1),tech_eval(2), tech_eval(3), tech_eval(4));
    end
    fclose(eval_file);

end
