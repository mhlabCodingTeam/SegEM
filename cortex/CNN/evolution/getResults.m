function results = getResults(cnets)

for i=1:length(cnets)
	cnet = cnets(i).loadLastCNN;
	temp = cnet.loadResults;
	if ~isempty(fieldnames(temp))
		results.data(i) = temp;
	end
end

end
