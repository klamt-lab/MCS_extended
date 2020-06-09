function cnap = block_non_standard_products(cnap)
% block_non_standard_products sets upper and lower bounds for source and
% sink reactions, like substrate supplies and metabolite outflow.
% Blocking the exchange of non-standard fermentation products is
% necessary for genome-scale setups. Genome scale models often hold exotic
% exchange reactions, e.g. for amino acids. In most cases, these exchanges don't
% need to be considered in the computation of MCS and it is sufficient to
% only consider (and block) the generic fermentation products in MCSs.
%
    % find exchange reactions (reactions that have only one enry, and that entry is -1)
    ex_reacs = find(sum((sum(abs(cnap.stoichMat))==1).*(cnap.stoichMat==-1)));
    % find carbon containing species and trace their exchange reactions
    specsWCarbon = regexp(CNAgetGenericSpeciesData_as_array(cnap,'fbc_chemicalFormula'), '.*C([A-Z]|\d).*', 'match');
    if isempty(specsWCarbon)
        specsWCarbon = regexp(cellstr(cnap.specNotes), '\[.*C([A-Z]|\d).*]', 'match');
    end
    specsWCarbon = find(~cellfun(@isempty,specsWCarbon));
    reacsWCarbon  = cellstr(cnap.reacID(ex_reacs( ismember(ex_reacs,find(sum(cnap.stoichMat(specsWCarbon,:))))),:));

    % RMin
    % Block all carbon supplies
   cnap.reacMin(ismember(cnap.reacID,reacsWCarbon)) = 0;

    % RMax
    % Block all carbon sinks
   cnap.reacMax(ex_reacs) = 0;
    % Open up selected carbon sinks again
    cnap.reacMax(~cellfun(@isempty,(regexp(cellstr(cnap.reacID),'BIOMASS_.*_core_.*')))) = 1000;
    cnap.reacMax(~cellfun(@isempty,(regexp(cellstr(cnap.reacID),'BIOMASS_.*_WT_.*')))) = 1000;
    cnap.reacMax(ismember(cnap.reacID,{     'EX_ac_e'...
                                            'EX_co2_e'...
                                            'EX_etoh_e'...
                                            'EX_for_e'...
                                            'EX_h2_e'...
                                            'EX_h2o2_e'...
                                            'EX_h2o_e'...
                                            'EX_h_e'...
                                            'EX_lac__D_e'...
                                            'EX_meoh_e'...
                                            'EX_o2_e'...
                                            'EX_succ_e'...
                                            'EX_tungs_e'})) = 1000;          
    cnap.reacMax(ismember(cnap.reacID,{     'DM_4crsol_c'...
                                            'DM_5drib_c'...
                                            'DM_aacald_c'...
                                            'DM_amob_c'...
                                            'DM_mththf_c'...
                                            'DM_oxam_c'})) = 1e-3;
    % This reaction is actually reversible. Uncomment for alternative computation setup:
    % cnap.reacMin(ismember(cnap.reacID,{'NADH16pp'})) = -1000;
end