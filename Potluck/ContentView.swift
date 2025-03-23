import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            NewEventView()
                .tabItem {
                    Label("New Event", systemImage: "plus.circle")
                }
            MyEventsView()   
                .tabItem {
                    Label("My Events", systemImage: "list.bullet")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
