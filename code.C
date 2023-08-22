#include <iostream>
#include <fstream>
#include <string>
#include <TH1.h>
#include <TCanvas.h>
#include <TLegend.h>
#include <TStyle.h>
#include <TImage.h>
#include <TFile.h>
#include <TTree.h>
using namespace std;

int IDUP[10],ISTUP[10],MOTHUP1[10],MOTHUP2[10],ICOLUP1[10],ICOLUP2[10];
float pp[5][10],VTIMUP[10],SPINUP[10];

void process_file(const char* input_file, const char* output_file) {
  
  bool check = false;
  int  count = 0;
  ifstream myfile (input_file);

  int NUP = -99;
  int IDPRUP;
  float XWGTUP, SCALUP, AQEDUP, AQCDUP;
  
  int event = 0;
  int npart = 0;
  int pdg[10];
  double px[10];
  double py[10];
  double pz[10];
  double en[10];
  double ma[10];
  
  TFile *f = new TFile(output_file, "RECREATE");
  TTree *tree = new TTree("T", "Tree");
  tree->Branch("event", &event, "event/I");
  tree->Branch("npart", &npart, "npart/I");
  tree->Branch("pdg", pdg, "pdg[npart]/I");
  tree->Branch("px", px, "px[npart]/D");
  tree->Branch("py", py, "py[npart]/D");
  tree->Branch("pz", pz, "pz[npart]/D");
  tree->Branch("en", en, "en[npart]/D");
  tree->Branch("ma", ma, "ma[npart]/D");
  
  
  if (myfile.is_open()){
    event = 0;
    while ( myfile.good() ){
      //
      char line[500]=" ";
      myfile.getline(line,500);
      //cout<<line<<endl;

      if(strcmp(line, "<mgrwt>")==0){ //was </event>
	//if(line==(string)"</event>"){
	if(count!=NUP){
	  cout<<"Problem with counting"<<endl;
	}
	else{
	  npart = NUP;
	  tree->Fill();
	}
	NUP   = -99;
	check = false;
      }
      
      //
      if(NUP>0){
	sscanf(line,"%d %d %d %d %d %d %f %f %f %f %f %f %f",&pdg[count],&ISTUP[count],&MOTHUP1[count],&MOTHUP2[count],&ICOLUP1[count],&ICOLUP2[count],&pp[0][count],&pp[1][count],&pp[2][count],&pp[3][count],&pp[4][count],&VTIMUP[count],&SPINUP[count]);
	//pdg[count] = IDUP[count];
	px[count]  = pp[0][count];
	py[count]  = pp[1][count];
	pz[count]  = pp[2][count];
	en[count]  = pp[3][count];
	ma[count]  = pp[4][count];
	//cout<<"PDG: "<<pdg[count]<<endl;
	//
	count++;
	check=false;
      }
      
      //
      if(check==true && NUP<0){
	sscanf(line,"%d %d %f %f %f %f",&NUP,&IDPRUP,&XWGTUP,&SCALUP,&AQEDUP,&AQCDUP);
	//cout<<"NUP = "<<NUP<<endl;
      }

      //
      if(strcmp(line, "<event>")==0){
	//if(line==(string)"<event>"){
	check = true;
	NUP   = -99;
	count = 0;
	event++;
	npart = 0;
	cout<<"Found event"<<endl;
      }

      if(strcmp(line, "</LesHouchesEvents>")==0){
	//if(line==(string)"</LesHouchesEvents>"){ 
	break;
      }
      
      //if(event>10) break;
    }
    myfile.close();
    f->Write();
    f->Close();
  }

}
  void process_files(const char* input_list) {
  ifstream input_file_list(input_list);
  if (!input_file_list) {
    cerr << "Não foi possível abrir a lista de arquivos: " << input_list << endl;
    return;
  }

  string input_file;
  while (getline(input_file_list, input_file)) {
    size_t last_dot = input_file.find_last_of(".");
    if (last_dot == string::npos) {
      cerr << "Arquivo de entrada inválido: " << input_file << endl;
      continue;
    }

    string output_file = input_file.substr(0, last_dot) + ".root";
    cout << "Processando " << input_file << " -> " << output_file << endl;
    process_file(input_file.c_str(), output_file.c_str());
  }
}

int code() {
  
  process_files("/eos/home-m/matheus/root_monopolos/input_files_list.txt");

  return 0;
}
