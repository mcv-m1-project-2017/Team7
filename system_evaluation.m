%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% SYSTEM EVALUATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function system_evaluation(directory, eval_file)

    addpath('evaluation/');

    %Evaluation results file
    eval_file = fopen(eval_file, 'w');
    val_dataset = txt2cell('train_dataset.txt', 'columns', 1);

    %Evaluation per technique
    for technique=1:3
        evaluation = [];

        for i=1:size(val_dataset,1)
            file_id=val_dataset(i,1);
            gt = imread(strcat(directory, '/mask/mask.', file_id{1}, '.png'));
            mask = imread(strcat('candidate_mask/mask.0',num2str(technique),'.', file_id{1}, '.png'));

            [pixelTP, pixelFP, pixelFN, pixelTN] = PerformanceAccumulationPixel(mask, gt);
            [pixelPrecision, pixelAccuracy, pixelSpecificity, pixelSensitivity] = ...
                PerformanceEvaluationPixel(pixelTP, pixelFP, pixelFN, pixelTN);

            evaluation = [evaluation; [pixelPrecision, pixelAccuracy, pixelSpecificity, pixelSensitivity, pixelTP, pixelFP, pixelFN]];
        end

        tech_eval = mean(evaluation);
        fprintf(eval_file, '%d\t%f\t%f\t%f\t%f\t%f\t%f\t%f\n', technique, tech_eval(1),tech_eval(2), ...
                tech_eval(3), tech_eval(4), tech_eval(5), tech_eval(6), tech_eval(7));
    end
    fclose(eval_file);

end
