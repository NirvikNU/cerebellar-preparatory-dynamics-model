function rows=submission_compare(a,b,path)
    rows={};if isequaln(a,b),return;end
    if ~strcmp(class(a),class(b))||~isequal(size(a),size(b))
        rows={entry(a,b,path)};return
    end
    if isstruct(a)
        if ~isequal(fieldnames(a),fieldnames(b)),rows{end+1}=entry(fieldnames(a),fieldnames(b),[path '.fieldnames']);end
        fields=intersect(fieldnames(a),fieldnames(b),'stable');
        for j=1:numel(a)
            for k=1:numel(fields)
                rows=[rows,submission_compare(a(j).(fields{k}),b(j).(fields{k}),sprintf('%s(%d).%s',path,j,fields{k}))]; %#ok<AGROW>
            end
        end
    elseif iscell(a)
        for j=1:numel(a),rows=[rows,submission_compare(a{j},b{j},sprintf('%s{%d}',path,j))];end %#ok<AGROW>
    else
        rows={entry(a,b,path)};
    end
end
function r=entry(a,b,path)
    r=struct('path',path,'classA',class(a),'classB',class(b),'sizeA',size(a),'sizeB',size(b), ...
        'valueA',preview(a),'valueB',preview(b),'differentElements',NaN,'maximumAbsoluteDifference',NaN);
    if (isnumeric(a)||islogical(a))&&isnumeric(b)&&isequal(size(a),size(b))
        d=~(a==b|(isnan(a)&isnan(b)));r.differentElements=nnz(d);
        r.maximumAbsoluteDifference=max(abs(double(a(d))-double(b(d))),[],'all');
    end
end
function v=preview(a)
    if (isnumeric(a)||islogical(a))&&numel(a)<=20
        v=a;
    elseif ischar(a)
        v=a(1:min(end,300));
    elseif isstring(a)&&isscalar(a)
        v=char(a);
    else
        v=['<' class(a) '>'];
    end
end
