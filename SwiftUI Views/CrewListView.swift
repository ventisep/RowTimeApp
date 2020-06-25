//
//  TestSwiftUIView.swift
//  RowTime
//
//  Created by Paul Ventisei on 31/05/2020.
//  Copyright © 2020 Paul Ventisei. All rights reserved.
//

import SwiftUI

@available(iOS 13.0.0, *)
struct CrewListView: View {
    @ObservedObject var crewListener: CrewListener
    @State var eventId: String = "2lryLSYS9KPf6D123VUo"
    @State private var time: String = "time"
    @State private var startTime: String = ""
    @State var selectedTab: Int = 1
    let timeFormat = DateFormatter()

        
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                List(crewListener.crewlist, id:\.self) { crew in
                    NavigationLink(destination: CrewDetailView(crew: crew)){
                    crewCell(crew: crew, crewListener: self.crewListener)
                    }
                }.navigationBarTitle("Crew Times", displayMode: .inline)
                .navigationBarItems(
                leading:
                    refreshButton(name: "refresh", crewListener: crewListener, eventId: $eventId) {
                        self.crewListener.setCrewListener(forEventId: self.eventId)
                    },
                trailing:
                    Button("Add Crew") {
                        print("add Crew")
                        
                })}.tabItem { Text("new") }.tag(1)
        Text("Tab Content 2").tabItem { Text("Tab Label 2") }.tag(2)
        }
    }
}

struct crewCell: View {
    var crew: Crew
    @ObservedObject var crewListener: CrewListener
    
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
                    self.crew.addTime(FirestoreDb: self.crewListener.FirestoreDb, time: Date(), stage: 0)
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

struct refreshButton: View {
    var name: String
    @ObservedObject var crewListener: CrewListener
    @Binding var eventId: String
    var action: () -> Void

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5).stroke(Color.red, lineWidth: 2)
            RoundedRectangle(cornerRadius: 5).fill(Color.white)
            Button(name, action: action).padding(5)
        }
    }
}






@available(iOS 13.0.0, *)
struct TestSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        CrewListView(crewListener: CrewListener())
    }
}


