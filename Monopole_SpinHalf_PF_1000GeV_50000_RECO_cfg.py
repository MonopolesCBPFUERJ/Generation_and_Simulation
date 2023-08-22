# Auto generated configuration file
# using: 
# Revision: 1.19 
# Source: /local/reps/CMSSW/CMSSW/Configuration/Applications/python/ConfigBuilder.py,v 
# with command line options: step3 --filein file:/eos/home-m/matheus/root_monopolos/SpinHalf_PF_root/Monopole_SpinHalf_PF_1000GeV_50000_AOD/Monopole_SpinHalf_PF_1000GeV_50000_HLT.root --fileout file:/eos/home-m/matheus/root_monopolos/SpinHalf_PF_root/Monopole_SpinHalf_PF_1000GeV_50000_AOD/Monopole_SpinHalf_PF_1000GeV_50000_RECO.root --mc --eventcontent AODSIM --datatier AODSIM --conditions 106X_upgrade2018_realistic_v16_L1v1 --step RAW2DIGI,L1Reco,RECO,RECOSIM --nThreads 8 --runUnscheduled --geometry DB:Extended --era Run2_2018 --customise=Configuration/DataProcessing/Utils.addMonitoring --customise_commands process.AODSIMoutput.outputCommands.append('keep *_generatorSmeared_*_*') \n process.AODSIMoutput.outputCommands.append('keep *_hybridSuperClusters_*_*') \n process.AODSIMoutput.outputCommands.append('keep *_multi5x5SuperClusters_multi5x5EndcapSuperClusters_*') \n process.AODSIMoutput.outputCommands.append('keep *_multi5x5SuperClusters_uncleanOnlyMulti5x5EndcapBasicClusters_*') \n process.AODSIMoutput.outputCommands.append('keep *_multi5x5SuperClusters_uncleanOnlyMulti5x5EndcapSuperClusters_*') \n process.AODSIMoutput.outputCommands.append('keep *_siStripClusters_*_*') \n process.AODSIMoutput.outputCommands.append('keep *_siPixelClusters_*_*') \n process.AODSIMoutput.outputCommands.append('drop *_generalTracks_*_*') \n process.AODSIMoutput.outputCommands.append('keep *_generalTracks_*_*') \n process.AODSIMoutput.outputCommands.append('drop *_generalTracks_QualityMasks_*') \n process.AODSIMoutput.outputCommands.append('keep *_ecalRecHit_EcalRecHitsEB_*') \n process.AODSIMoutput.outputCommands.append('keep *_ecalRecHit_EcalRecHitsEE_*') \n process.AODSIMoutput.outputCommands.append('keep *_hbhereco_*_*') \n process.Timing.summaryOnly = cms.untracked.bool(True) \n process.Timing.excessiveTimeThreshold = cms.untracked.double(30.0) \n --python_filename SpinHalf_PF_configs/Monopole_SpinHalf_PF_1000GeV_50000_RECO_cfg.py --no_exec -n -1
import FWCore.ParameterSet.Config as cms

from Configuration.Eras.Era_Run2_2018_cff import Run2_2018

process = cms.Process('RECO',Run2_2018)

# import of standard configurations
process.load('Configuration.StandardSequences.Services_cff')
process.load('SimGeneral.HepPDTESSource.pythiapdt_cfi')
process.load('FWCore.MessageService.MessageLogger_cfi')
process.load('Configuration.EventContent.EventContent_cff')
process.load('SimGeneral.MixingModule.mixNoPU_cfi')
process.load('Configuration.StandardSequences.GeometryRecoDB_cff')
process.load('Configuration.StandardSequences.MagneticField_cff')
process.load('Configuration.StandardSequences.RawToDigi_cff')
process.load('Configuration.StandardSequences.L1Reco_cff')
process.load('Configuration.StandardSequences.Reconstruction_cff')
process.load('Configuration.StandardSequences.RecoSim_cff')
process.load('Configuration.StandardSequences.EndOfProcess_cff')
process.load('Configuration.StandardSequences.FrontierConditions_GlobalTag_cff')

process.maxEvents = cms.untracked.PSet(
    input = cms.untracked.int32(-1)
)

# Input source
process.source = cms.Source("PoolSource",
    fileNames = cms.untracked.vstring('file:/eos/home-m/matheus/root_monopolos/SpinHalf_PF_root/Monopole_SpinHalf_PF_1000GeV_50000_AOD/Monopole_SpinHalf_PF_1000GeV_50000_HLT.root'),
    secondaryFileNames = cms.untracked.vstring()
)

process.options = cms.untracked.PSet(

)

# Production Info
process.configurationMetadata = cms.untracked.PSet(
    annotation = cms.untracked.string('step3 nevts:-1'),
    name = cms.untracked.string('Applications'),
    version = cms.untracked.string('$Revision: 1.19 $')
)

# Output definition

process.AODSIMoutput = cms.OutputModule("PoolOutputModule",
    compressionAlgorithm = cms.untracked.string('LZMA'),
    compressionLevel = cms.untracked.int32(4),
    dataset = cms.untracked.PSet(
        dataTier = cms.untracked.string('AODSIM'),
        filterName = cms.untracked.string('')
    ),
    eventAutoFlushCompressedSize = cms.untracked.int32(31457280),
    fileName = cms.untracked.string('file:/eos/home-m/matheus/root_monopolos/SpinHalf_PF_root/Monopole_SpinHalf_PF_1000GeV_50000_AOD/Monopole_SpinHalf_PF_1000GeV_50000_RECO.root'),
    outputCommands = process.AODSIMEventContent.outputCommands
)

# Additional output definition

# Other statements
from Configuration.AlCa.GlobalTag import GlobalTag
process.GlobalTag = GlobalTag(process.GlobalTag, '106X_upgrade2018_realistic_v16_L1v1', '')

# Path and EndPath definitions
process.raw2digi_step = cms.Path(process.RawToDigi)
process.L1Reco_step = cms.Path(process.L1Reco)
process.reconstruction_step = cms.Path(process.reconstruction)
process.recosim_step = cms.Path(process.recosim)
process.endjob_step = cms.EndPath(process.endOfProcess)
process.AODSIMoutput_step = cms.EndPath(process.AODSIMoutput)

# Schedule definition
process.schedule = cms.Schedule(process.raw2digi_step,process.L1Reco_step,process.reconstruction_step,process.recosim_step,process.endjob_step,process.AODSIMoutput_step)
from PhysicsTools.PatAlgos.tools.helpers import associatePatAlgosToolsTask
associatePatAlgosToolsTask(process)

#Setup FWK for multithreaded
process.options.numberOfThreads=cms.untracked.uint32(8)
process.options.numberOfStreams=cms.untracked.uint32(0)
process.options.numberOfConcurrentLuminosityBlocks=cms.untracked.uint32(1)

# customisation of the process.

# Automatic addition of the customisation function from Configuration.DataProcessing.Utils
from Configuration.DataProcessing.Utils import addMonitoring 

#call to customisation function addMonitoring imported from Configuration.DataProcessing.Utils
process = addMonitoring(process)

# End of customisation functions
#do not add changes to your config after this point (unless you know what you are doing)
from FWCore.ParameterSet.Utilities import convertToUnscheduled
process=convertToUnscheduled(process)


# Customisation from command line

process.AODSIMoutput.outputCommands.append('keep *_generatorSmeared_*_*') 
process.AODSIMoutput.outputCommands.append('keep *_hybridSuperClusters_*_*') 
process.AODSIMoutput.outputCommands.append('keep *_multi5x5SuperClusters_multi5x5EndcapSuperClusters_*') 
process.AODSIMoutput.outputCommands.append('keep *_multi5x5SuperClusters_uncleanOnlyMulti5x5EndcapBasicClusters_*') 
process.AODSIMoutput.outputCommands.append('keep *_multi5x5SuperClusters_uncleanOnlyMulti5x5EndcapSuperClusters_*') 
process.AODSIMoutput.outputCommands.append('keep *_siStripClusters_*_*') 
process.AODSIMoutput.outputCommands.append('keep *_siPixelClusters_*_*') 
process.AODSIMoutput.outputCommands.append('drop *_generalTracks_*_*') 
process.AODSIMoutput.outputCommands.append('keep *_generalTracks_*_*') 
process.AODSIMoutput.outputCommands.append('drop *_generalTracks_QualityMasks_*') 
process.AODSIMoutput.outputCommands.append('keep *_ecalRecHit_EcalRecHitsEB_*') 
process.AODSIMoutput.outputCommands.append('keep *_ecalRecHit_EcalRecHitsEE_*') 
process.AODSIMoutput.outputCommands.append('keep *_hbhereco_*_*') 
process.Timing.summaryOnly = cms.untracked.bool(True) 
process.Timing.excessiveTimeThreshold = cms.untracked.double(30.0) 

#Have logErrorHarvester wait for the same EDProducers to finish as those providing data for the OutputModule
from FWCore.Modules.logErrorHarvester_cff import customiseLogErrorHarvesterUsingOutputCommands
process = customiseLogErrorHarvesterUsingOutputCommands(process)

# Add early deletion of temporary data products to reduce peak memory need
from Configuration.StandardSequences.earlyDeleteSettings_cff import customiseEarlyDelete
process = customiseEarlyDelete(process)
# End adding early deletion
