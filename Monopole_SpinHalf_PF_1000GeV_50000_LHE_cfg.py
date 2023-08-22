# Auto generated configuration file
# using: 
# Revision: 1.19 
# Source: /local/reps/CMSSW/CMSSW/Configuration/Applications/python/ConfigBuilder.py,v 
# with command line options: step1 --filein file:/eos/home-m/matheus/root_monopolos/SpinHalf_PF_root/Monopole_SpinHalf_PF_1000GeV_50000.lhe --fileout file:/eos/home-m/matheus/root_monopolos/SpinHalf_PF_root/Monopole_SpinHalf_PF_1000GeV_50000_AOD/Monopole_SpinHalf_PF_1000GeV_50000.root --mc --eventcontent LHE --datatier LHE --conditions 106X_upgrade2018_realistic_v16_L1v1 --step NONE --python_filename SpinHalf_PF_configs/Monopole_SpinHalf_PF_1000GeV_50000_LHE_cfg.py --no_exec -n 10 --customise_commands process.source.firstLuminosityBlock = cms.untracked.uint32(3)
import FWCore.ParameterSet.Config as cms



process = cms.Process('LHE')

# import of standard configurations
process.load('FWCore.MessageService.MessageLogger_cfi')
process.load('Configuration.EventContent.EventContent_cff')
process.load('SimGeneral.MixingModule.mixNoPU_cfi')
process.load('Configuration.StandardSequences.FrontierConditions_GlobalTag_cff')

process.maxEvents = cms.untracked.PSet(
    input = cms.untracked.int32(10)
)

# Input source
process.source = cms.Source("LHESource",
    fileNames = cms.untracked.vstring('file:/eos/home-m/matheus/root_monopolos/SpinHalf_PF_root/Monopole_SpinHalf_PF_1000GeV_50000.lhe')
)

process.options = cms.untracked.PSet(

)

# Production Info
process.configurationMetadata = cms.untracked.PSet(
    annotation = cms.untracked.string('step1 nevts:10'),
    name = cms.untracked.string('Applications'),
    version = cms.untracked.string('$Revision: 1.19 $')
)

# Output definition

process.LHEoutput = cms.OutputModule("PoolOutputModule",
    dataset = cms.untracked.PSet(
        dataTier = cms.untracked.string('LHE'),
        filterName = cms.untracked.string('')
    ),
    fileName = cms.untracked.string('file:/eos/home-m/matheus/root_monopolos/SpinHalf_PF_root/Monopole_SpinHalf_PF_1000GeV_50000_AOD/Monopole_SpinHalf_PF_1000GeV_50000.root'),
    outputCommands = process.LHEEventContent.outputCommands,
    splitLevel = cms.untracked.int32(0)
)

# Additional output definition

# Other statements
from Configuration.AlCa.GlobalTag import GlobalTag
process.GlobalTag = GlobalTag(process.GlobalTag, '106X_upgrade2018_realistic_v16_L1v1', '')

# Path and EndPath definitions
process.LHEoutput_step = cms.EndPath(process.LHEoutput)

# Schedule definition
process.schedule = cms.Schedule(process.LHEoutput_step)
from PhysicsTools.PatAlgos.tools.helpers import associatePatAlgosToolsTask
associatePatAlgosToolsTask(process)


# Customisation from command line

process.source.firstLuminosityBlock = cms.untracked.uint32(3)
# Add early deletion of temporary data products to reduce peak memory need
from Configuration.StandardSequences.earlyDeleteSettings_cff import customiseEarlyDelete
process = customiseEarlyDelete(process)
# End adding early deletion
