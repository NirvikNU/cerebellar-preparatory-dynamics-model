function [differences,events,rawDifferences]=pf_compare_native(root,name,a,b,master,actual)
    % Verify fixed native bytes before comparing only approved editor metadata.
    policy=jsondecode(fileread(fullfile(root,'data/paper_ready/final_v3/graphics_validation/native_editor_rule.json')));
    approved='4C034AC7626504AA55BEFE192D8D9DBA4675E42E46190569E36BEC6765266EC7';
    assert(strcmp(policy.approvedSourceSHA256,approved),'Publication:NativePolicy','Unapproved native policy.');
    rawDifferences=submission_compare(a,b,'native');differences=rawDifferences;events={};
    hit=find(strcmp({policy.eligiblePanels.panel},name));assembly=isempty(hit);
    source=bytes(master);
    if assembly
        policy=jsondecode(fileread(fullfile(root,'data/paper_ready/final_v3/graphics_validation/assembly_editor_rule.json')));
        assert(strcmp(policy.approvedSourceSHA256,'FF590FE555BF7049A4C068BF51BF07E5D65DBA7C50AE8663B379AEB51047AF3F') ...
            &&strcmp(policy.extendsPanelRuleSHA256,approved),'Publication:AssemblyPolicy','Unapproved assembly policy.');
        hit=find(strcmp({policy.eligibleAssemblies.assembly},name));
        if isempty(hit),return;end
        assert(isscalar(hit));pin=policy.eligibleAssemblies(hit);
        assert(strcmp(sha(source),pin.canonicalSHA256),'Publication:AssemblyPolicyBytes','Changed canonical assembly.');
    else
        assert(isscalar(hit));pin=policy.eligiblePanels(hit);reopened=bytes(actual);
        assert(strcmp(sha(source),pin.sha256)&&isequal(source,reopened), ...
            'Publication:NativePolicyBytes','Eligible native FIG must retain its exact approved bytes: %s',name);
    end
    if isempty(rawDifferences),return;end
    if ~isequal(size(a.handleNodes),size(b.handleNodes))||a.originalFindallCount~=b.originalFindallCount,return;end
    for n=1:numel(a.handleNodes)
        node=a.handleNodes{n};other=b.handleNodes{n};p=node.properties;q=other.properties;
        if ~strcmp(node.class,'matlab.graphics.axis.Axes')||~strcmp(other.class,node.class),continue;end
        used=0;
        for k=1:numel(policy.eligibleRoles)
            role=policy.eligibleRoles{k};ref=p.(role);test=q.(role);
            if ~isequaln(ref,test)||~isstruct(ref)||~isfield(ref,'references')||~isscalar(ref.references),continue;end
            id=ref.references;
            if id<1||id>numel(a.handleNodes),continue;end
            left=a.handleNodes{id};right=b.handleNodes{id};
            if ~strcmp(left.class,policy.textClass)||~strcmp(right.class,policy.textClass),continue;end
            x=left.properties.Interactions;y=right.properties.Interactions;
            if isequaln(x,y),continue;end
            if assembly
                assert(strcmp(p.Visible,'off')&&strcmp(q.Visible,'off') ...
                    &&isempty(left.properties.String)&&isempty(right.properties.String) ...
                    &&isequaln(left.properties.String,right.properties.String), ...
                    'Publication:AssemblyEditorIdentity','Assembly exception requires identical empty labels on hidden axes.');
            end
            assert(permitted(x)&&permitted(y),'Publication:NativeEditorValue','Unapproved axes-label editor value.');
            assert(strcmp(version,policy.qualifiedEnvironment.matlab) ...
                &&get(groot,'ScreenPixelsPerInch')==policy.qualifiedEnvironment.screenPixelsPerInch, ...
                'Publication:NativeEditorEnvironment','Unqualified native readback environment.');
            used=used+1;assert(used<=policy.maximumDifferencesPerAxes);
            events{end+1}=struct('panel',name,'assemblyOnly',assembly,'axisClass',node.class,'axisPosition',p.Position, ...
                'axisVisible',p.Visible,'labelString',left.properties.String, ...
                'labelRole',role,'referenceClass',class(x),'referenceSize',size(x),'referenceValue',x, ...
                'actualClass',class(y),'actualSize',size(y),'actualValue',y); %#ok<AGROW>
            token=struct('verifiedRuntimeLabelEditingMetadata',true);
            a.handleNodes{id}.properties.Interactions=token;b.handleNodes{id}.properties.Interactions=token;
        end
    end
    differences=submission_compare(a,b,'native');
end

function yes=permitted(value)
    yes=isa(value,'double')&&isequal(size(value),[0 0]);
    if yes,return;end
    yes=isstruct(value)&&isscalar(value)&&isequal(sort(fieldnames(value)),{'properties';'valueClass'}) ...
        &&ischar(value.valueClass)&&isrow(value.valueClass) ...
        &&strcmp(value.valueClass,'matlab.graphics.interaction.interactions.EditInteraction') ...
        &&isstruct(value.properties)&&isscalar(value.properties)&&isempty(fieldnames(value.properties));
end

function out=bytes(file)
    fid=fopen(file,'rb');assert(fid>=0);guard=onCleanup(@()fclose(fid));out=fread(fid,Inf,'*uint8');
end

function out=sha(data)
    md=java.security.MessageDigest.getInstance('SHA-256');md.update(data);
    out=upper(reshape(dec2hex(typecast(md.digest(),'uint8'),2).',1,[]));
end
