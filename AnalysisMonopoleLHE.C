#define AnalysisMonopoleLHE_cxx
#include "AnalysisMonopoleLHE.h"
#include <TH2.h>
#include <TStyle.h>
#include <TCanvas.h>

void AnalysisMonopoleLHE::Loop()
{
  //   In a ROOT session, you can do:
  //      root> .L AnalysisMonopoleLHE.C
  //      root> AnalysisMonopoleLHE t
  //      root> t.GetEntry(12); // Fill t data members with entry number 12
  //      root> t.Show();       // Show values of entry 12
  //      root> t.Show(16);     // Read and show values of entry 16
  //      root> t.Loop();       // Loop on all entries
  //
  
  //     This is the loop skeleton where:
  //    jentry is the global entry number in the chain
  //    ientry is the entry number in the current Tree
  //  Note that the argument to GetEntry must be:
  //    jentry for TChain::GetEntry
  //    ientry for TTree::GetEntry and TBranch::GetEntry
  //
  //       To read only selected branches, Insert statements like:
  // METHOD1:
  //    fChain->SetBranchStatus("*",0);  // disable all branches
  //    fChain->SetBranchStatus("branchname",1);  // activate branchname
  // METHOD2: replace line
  //    fChain->GetEntry(jentry);       //read all branches
  //by  b_branchname->GetEntry(ientry); //read only this branch
  if (fChain == 0) return;

  Long64_t nentries = fChain->GetEntriesFast();
  Long64_t nbytes = 0, nb = 0;

  TLorentzVector particle(0.,0.,0.,0.);

  TH1F *eta = new TH1F("eta","Eta(monopole)",40,-5.,5.);
  TH1F *pt_hist = new TH1F("pt_hist", "Transverse Momentum (monopole)", 100, 0, 5000);
  TH1F *phi_hist = new TH1F("phi_hist", "Azimuthal Angle (phi) (monopole)", 64, -3.2, 3.2);
  TH1F *invMass_hist = new TH1F("invMass_hist", "Invariant Mass", 100, 0, 10000);

  
  for (Long64_t jentry=0; jentry<nentries;jentry++) {
    Long64_t ientry = LoadTree(jentry);
    if (ientry < 0) break;
    nb = fChain->GetEntry(jentry);   nbytes += nb;
    // if (Cut(ientry) < 0) continue;
    for (Int_t i=0; i<npart; i++) {
        if (abs(pdg[i]) == 4110000) {
            particle.SetPxPyPzE(px[i], py[i], pz[i], en[i]);
            eta->Fill(particle.Eta());
            pt_hist->Fill(pt[i]);
            phi_hist->Fill(phi[i]);
            invMass_hist->Fill(invMass);
        }
    }
}

  TCanvas *c2 = new TCanvas("c2", "c2", 1000, 1000);
  c2->Divide(2, 2);
  c2->cd(1);
  eta->Draw();

  c2->cd(2);
  pt_hist->Draw();

  c2->cd(3);
  phi_hist->Draw();

  c2->cd(4);
  invMass_hist->Draw();

  c2->Update();

}
