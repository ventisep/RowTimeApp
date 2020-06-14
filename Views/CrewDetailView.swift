//
//  SwiftUIView.swift
//  RowTime
//
//  Created by Paul Ventisei on 11/06/2020.
//  Copyright © 2020 Paul Ventisei. All rights reserved.
//

import SwiftUI

struct CrewDetailView: View {
    var crew: Crew?
    
    var body: some View {
        Text("Hello, World!\(crew!.crewName)")
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        CrewDetailView(crew: nil)
    }
}
