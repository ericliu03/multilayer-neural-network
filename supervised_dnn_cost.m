function [cost, grad, pred_prob] = supervised_dnn_cost( theta, ei, data, labels, pred_only)
%SPNETCOSTSLAVE Slave cost function for simple phone net
%   Does all the work of cost / gradient computation
%   Returns cost broken into cross-entropy, weight norm, and prox reg
%        components (ceCost, wCost, pCost)
%   label: 60000,1
m = size(data,2);
%% default values
po = false;
if exist('pred_only','var')
    po = pred_only;
end;

%% reshape into network
stack = params2stack(theta, ei);
numHidden = numel(ei.layer_sizes) - 1;
hAct = cell(numHidden+1, 1);
gradStack = cell(numHidden+1, 1);

%% forward prop
input = data;
num_layers = size(ei.layer_sizes,2);
output = cell(num_layers+1,1);
output{1} = input;

for i = 1:num_layers
    output{i+1} = stack{i}.W * output{i} + repmat(stack{i}.b, 1, m);
    if i == num_layers
        for_cost = output{i+1};
    end
    output{i+1} = sigmoid(output{i+1});
end

pred_prob = output{num_layers+1}; % (10,m)

%% return here if only predictions desired.
if po
    cost = -1; ceCost = -1; wCost = -1; numCorrect = -1;
    grad = [];
    return;
end;

%% compute cost
%%% YOUR CODE HERE %%%
M = exp(for_cost);
p = bsxfun(@rdivide, M, sum(M));
groundTruth = full(sparse(labels, 1:m, 1));
cost = - 1/m *groundTruth(:)' * log(p(:));

%% compute gradients using backpropagation
%%% YOUR CODE HERE %%%
epsilon = - (groundTruth - p);

for i = num_layers:-1:1
    
    gradStack{i} = struct;
    gradStack{i}.W = epsilon * output{i}'/m;
    gradStack{i}.b = sum(epsilon,2)/m;
    epsilon = (stack{i}.W'*epsilon).*output{i}.*(1-output{i});
    
end

%% compute weight penalty cost and gradient for non-bias terms
%%% YOUR CODE HERE %%%
% pCost = 0;
% for i = 1:num_layers
%     pCost = pCost + sum(stack{i}.W(:).^2);
% end
% cost = cost + lambda * pCost / 2;

%% reshape gradients into vector
[grad] = stack2params(gradStack);
end




