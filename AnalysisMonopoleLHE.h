//////////////////////////////////////////////////////////
// This class has been automatically generated on
// Wed Mar 16 17:02:46 2016 by ROOT version 6.06/00
// from TTree T/Tree
// found on file: myMonopoleFile.root
//////////////////////////////////////////////////////////

#ifndef AnalysisMonopoleLHE_h
#define AnalysisMonopoleLHE_h

#include <TROOT.h>
#include <TChain.h>
#include <TFile.h>

// Header file for the classes stored in the TTree if any.

class AnalysisMonopoleLHE {
public :
   TTree          *fChain;   //!pointer to the analyzed TTree or TChain
   Int_t           fCurrent; //!current Tree number in a TChain

// Fixed size dimensions of array or collections stored in the TTree if any.

   // Declaration of leaf types
   Int_t           event;
   Int_t           npart;
   Int_t           pdg[4];  //[npart]
   Double_t        px[4];   //[npart]
   Double_t        py[4];   //[npart]
   Double_t        pz[4];   //[npart]
   Double_t        en[4];   //[npart]
   Double_t        ma[4];   //[npart]
   Double_t        invMass;
   Double_t        pt[4];   //[npart]
   Double_t        phi[4];  //[npart]


   // List of branches
   TBranch        *b_event;   //!
   TBranch        *b_npart;   //!
   TBranch        *b_pdg;   //!
   TBranch        *b_px;   //!
   TBranch        *b_py;   //!
   TBranch        *b_pz;   //!
   TBranch        *b_en;   //!
   TBranch        *b_ma;   //!
   TBranch        *b_invMass;   //!
   TBranch        *b_pt;   //!
   TBranch        *b_phi;   //!


   AnalysisMonopoleLHE(TTree *tree=0);
   virtual ~AnalysisMonopoleLHE();
   virtual Int_t    Cut(Long64_t entry);
   virtual Int_t    GetEntry(Long64_t entry);
   virtual Long64_t LoadTree(Long64_t entry);
   virtual void     Init(TTree *tree);
   virtual void     Loop();
   virtual Bool_t   Notify();
   virtual void     Show(Long64_t entry = -1);
};

#endif

#ifdef AnalysisMonopoleLHE_cxx
AnalysisMonopoleLHE::AnalysisMonopoleLHE(TTree *tree) : fChain(0) 
{
// if parameter tree is not specified (or zero), connect the file
// used to generate this class and read the Tree.
   if (tree == 0) {
      TFile *f = (TFile*)gROOT->GetListOfFiles()->FindObject("/eos/home-m/matheus/root_monopolos/Spin0_4500GeV_5000Events.root");
      if (!f || !f->IsOpen()) {
         f = new TFile("/eos/home-m/matheus/root_monopolos/Spin0_4500GeV_5000Events.root");
      }
      f->GetObject("T",tree);

   }
   Init(tree);
}

AnalysisMonopoleLHE::~AnalysisMonopoleLHE()
{
   if (!fChain) return;
   delete fChain->GetCurrentFile();
}

Int_t AnalysisMonopoleLHE::GetEntry(Long64_t entry)
{
// Read contents of entry.
   if (!fChain) return 0;
   return fChain->GetEntry(entry);
}
Long64_t AnalysisMonopoleLHE::LoadTree(Long64_t entry)
{
// Set the environment to read one entry
   if (!fChain) return -5;
   Long64_t centry = fChain->LoadTree(entry);
   if (centry < 0) return centry;
   if (fChain->GetTreeNumber() != fCurrent) {
      fCurrent = fChain->GetTreeNumber();
      Notify();
   }
   return centry;
}


void CalculateInvariantMassPtPhi() {
   for (Int_t i = 0; i < npart; i++) {
      pt[i] = sqrt(px[i] * px[i] + py[i] * py[i]);
      phi[i] = atan2(py[i], px[i]);
   }

   Double_t totalPx = 0.0;
   Double_t totalPy = 0.0;
   Double_t totalPz = 0.0;
   Double_t totalE = 0.0;

   for (Int_t i = 0; i < npart; i++) {
      totalPx += px[i];
      totalPy += py[i];
      totalPz += pz[i];
      totalE += en[i];
   }

   Double_t massSquared = totalE * totalE - totalPx * totalPx - totalPy * totalPy - totalPz * totalPz;
   invMass = (massSquared > 0.0) ? sqrt(massSquared) : -sqrt(-massSquared);
}

void AnalysisMonopoleLHE::Init(TTree *tree)
{
   // The Init() function is called when the selector needs to initialize
   // a new tree or chain. Typically here the branch addresses and branch
   // pointers of the tree will be set.
   // It is normally not necessary to make changes to the generated
   // code, but the routine can be extended by the user if needed.
   // Init() will be called many times when running on PROOF
   // (once per file to be processed).

   // Set branch addresses and branch pointers
   if (!tree) return;
   fChain = tree;
   fCurrent = -1;
   fChain->SetMakeClass(1);

   fChain->SetBranchAddress("event", &event, &b_event);
   fChain->SetBranchAddress("npart", &npart, &b_npart);
   fChain->SetBranchAddress("pdg", pdg, &b_pdg);
   fChain->SetBranchAddress("px", px, &b_px);
   fChain->SetBranchAddress("py", py, &b_py);
   fChain->SetBranchAddress("pz", pz, &b_pz);
   fChain->SetBranchAddress("en", en, &b_en);
   fChain->SetBranchAddress("ma", ma, &b_ma);
   fChain->SetBranchAddress("invMass", &invMass, &b_invMass);
   fChain->SetBranchAddress("pt", pt, &b_pt);
   fChain->SetBranchAddress("phi", phi, &b_phi);
   Notify();
}



Bool_t AnalysisMonopoleLHE::Notify()
{
   // The Notify() function is called when a new file is opened. This
   // can be either for a new TTree in a TChain or when when a new TTree
   // is started when using PROOF. It is normally not necessary to make changes
   // to the generated code, but the routine can be extended by the
   // user if needed. The return value is currently not used.

   return kTRUE;
}

void AnalysisMonopoleLHE::Show(Long64_t entry)
{
// Print contents of entry.
// If entry is not specified, print current entry
   if (!fChain) return;
   fChain->Show(entry);
}
Int_t AnalysisMonopoleLHE::Cut(Long64_t entry)
{
// This function may be called from Loop.
// returns  1 if entry is accepted.
// returns -1 otherwise.
   return 1;
}
#endif // #ifdef AnalysisMonopoleLHE_cxx
