//
//  TestSwiftUIView.swift
//  RowTime
//
//  Created by Paul Ventisei on 31/05/2020.
//  Copyright © 2020 Paul Ventisei. All rights reserved.
//

import SwiftUI

@available(iOS 13.0.0, *)
struct TestSwiftUIView: View {
    @ObservedObject var crewdata: TestCrewListener
    @State private var time: String = "time"
    @State private var startTime: String = ""
    let timeFormat = DateFormatter()

        
    var body: some View {
        TabView(selection: /*@START_MENU_TOKEN@*/ /*@PLACEHOLDER=Selection@*/.constant(1)/*@END_MENU_TOKEN@*/) {
        NavigationView {
            List(crewdata.crewlist, id:\.self) { crew in

                NavigationLink(destination: TestCrewView(crew: crew)){
                crewCell(crew: crew, crewdata: self.crewdata)
                }
            }.navigationBarTitle("Crew Times")
        }.tabItem { Text("In Progress") }.tag(1)
        /*@START_MENU_TOKEN@*/Text("Tab Content 2").tabItem { Text("Tab Label 2") }.tag(2)/*@END_MENU_TOKEN@*/
        }

    }
}

struct crewCell: View {
    var crew: Crew
    @ObservedObject var crewdata: TestCrewListener
    
    var body: some View {
        VStack (alignment: .leading){
            HStack{
                Text(String(crew.crewNumber))
                    .font(.title)
                    .foregroundColor(.blue)
                Text(crew.crewName)
                    .font(.title)
            }
            HStack(alignment: .lastTextBaseline) {
                Text("Start: \(crew.startTimeLocal?.description ?? " ") ").onTapGesture {
                    self.crew.addTime(FirestoreDb: self.crewdata.FirestoreDb, time: Date(), stage: 0)
                }
                Spacer()
                Text("Finished: ")
                Spacer()
                Text("Time:")
            }.foregroundColor(.secondary)
        }.onTapGesture {
            print("hello")
        }
    }
}

@available(iOS 13.0.0, *)
struct TestSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        TestSwiftUIView(crewdata: TestCrewListener())
    }
}
