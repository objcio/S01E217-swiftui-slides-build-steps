//
//  ContentView.swift
//  Slides
//
//  Created by Chris Eidhof on 11.08.20.
//  Copyright © 2020 Chris Eidhof. All rights reserved.
//

import SwiftUI

struct SlideContainer<S: View, Theme: ViewModifier>: View {
    var slides: [S]
    var theme: Theme
    @State var currentSlide = 0
    @State var numberOfSteps = 1
    @State var currentStep = 0
    
    func previous() {
        if currentSlide > 0  {
            currentSlide -= 1
            currentStep = 0
        }
    }
    
    func next() {
        if currentStep + 1 < numberOfSteps {
            withAnimation(.default) {
                currentStep += 1
            }
        } else if currentSlide + 1 < slides.count {
            currentSlide += 1
            currentStep = 0
        }
    }
    
    var body: some View {
        VStack(spacing: 30) {
            HStack {
                Button("Previous") { self.previous() }
                Text("Slide \(currentSlide + 1) of \(slides.count) — Step \(currentStep + 1) of \(numberOfSteps)")
                Button("Next") { self.next() }
            }
            slides[currentSlide]
                .onPreferenceChange(StepsKey.self, perform: {
                    self.numberOfSteps = $0
                })
                .environment(\.currentStep, currentStep)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .modifier(theme)
                .aspectRatio(CGSize(width: 16, height: 9), contentMode: .fit)
                .border(Color.black)
        }
    }
}

extension SlideContainer where Theme == EmptyModifier {
    init(slides: [S]) {
        self.init(slides: slides, theme: .identity)
    }
}

struct MyTheme: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(.white)
            .background(Color.blue)
            .font(.custom("Avenir", size: 48))
    
        
    }
}

struct StepsKey: PreferenceKey {
    static let defaultValue: Int = 1
    static func reduce(value: inout Int, nextValue: () -> Int) {
        value = nextValue()
    }
}

struct CurrentStepKey: EnvironmentKey {
    static let defaultValue = 1
}

extension EnvironmentValues {
    var currentStep: Int {
        get { self[CurrentStepKey.self] }
        set { self[CurrentStepKey.self] = newValue }
    }
}

struct Slide<Content: View>: View {
    var steps: Int = 1
    let content: (Int) -> Content
    @Environment(\.currentStep) var step: Int
    
    var body: some View {
        content(step)
            .preference(key: StepsKey.self, value: steps)
    }
}

struct ImageSlide: View {
    var body: some View {
        Slide(steps: 2) { step in
            Image(systemName: "tortoise")
                .frame(maxWidth: .infinity, alignment: step > 0 ? .trailing :  .leading)
                .padding(50)
        }
            
    }
}

struct ContentView: View {
    var body: some View {
        SlideContainer(slides: [
            AnyView(Text("Hello, World!")),
            AnyView(ImageSlide())
        ], theme: MyTheme())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
