//
//  ContentView.swift
//  iOSApp
//
//  Created by dedeepya reddy salla on 12/08/25.
//

// Your task is to finish this application to satisfy requirements below and make it look like on the attached screenshots. Try to use 80/20 principle.
// Good luck! 🍀

// 1. Setup UI of the ContentView. Try to keep it as similar as possible.
// 2. Subscribe to the timer and count seconds down from 60 to 0 on the ContentView.
// 3. Present PaymentModalView as a sheet after tapping on the "Open payment" button.
// 4. Load payment types from repository in PaymentInfoView. Show loader when waiting for the response. No need to handle error.
// 5. List should be refreshable.
// 6. Show search bar for the list to filter payment types. You can filter items in any way.
// 7. User should select one of the types on the list. Show checkmark next to the name when item is selected.
// 8. Show "Done" button in navigation bar only if payment type is selected. Tapping this button should hide the modal.
// 9. Show "Finish" button on ContentScreen only when "payment type" was selected.
// 10. Replace main view with "FinishView" when user taps on the "Finish" button.

import SwiftUI
import Combine

//class Model: ObservableObject {
//
//    let processDurationInSeconds: Int = 60
//    var repository: PaymentTypesRepository = PaymentTypesRepositoryImplementation()
//    var cancellables: [AnyCancellable] = []
//
//    init() {
//        Timer.publish(every: 1, on: .main, in: .common)
//                    .autoconnect()
//                    .store(in: &cancellables)
//    }
//}

enum Constants {
    static let finish = "Finish"
    static let openPayment = "Open Payment"
}

// MARK: Views

struct ContentView: View {
    var body: some View {
        InitialScreenView()
    }
}

struct InitialScreenView: View {
    @StateObject private var viewModel = InitialScreenViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.blue
                    .ignoresSafeArea()
                
                mainView
            }
        }
    }
    
    var mainView: some View {
        VStack {
            Spacer()
            
            CountDownTimerView()
            
            Spacer()
            
            if !viewModel.hideButtons {
                
                OpenPaymentView()
                
                if viewModel.showFinish {
                    FinishView()
                }
            }
        }
        .padding(10)
    }
}

struct CountDownTimerView: View {
    @StateObject private var viewModel = CountDownTimerViewModel()

    var body: some View {
        VStack(alignment: .center) {

            Text("You have only \(viewModel.timer) seconds left to get the discount")
                .font(.title)
                .bold()
                .foregroundColor(.white)
        }
        .background(.blue)
    }
}

struct OpenPaymentView: View {
    @StateObject private var viewModel = OpenPaymentViewModel()
    
    var body: some View {
        Button {
            viewModel.openPayment()
        } label: {
            NextScreenTitleView(title: viewModel.buttonTitle)
        }
        .sheet(isPresented: $viewModel.showPayments) {
            PaymentModalView()
        }
    }
}

struct FinishView: View {
    var body: some View {
        NavigationLink(destination: CongratulationsView()) {
            NextScreenTitleView(title: "Finish")
        }
    }
}

struct CongratulationsView: View {
    var body: some View {
        Text("Congratulations")
    }
}

struct PaymentModalView: View {
    @StateObject var viewModel = PaymentInfoViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        // Load payment types when presenting the view. Repository has 2 seconds delay.
        // User should select an item.
        // Show checkmark in a selected row.
        //
        // No need to handle error.
        // Use refreshing mechanism to reload the list items.
        // Show loader before response comes.
        // Show search bar to filter payment types
        //
        // Finish button should be only available if user selected payment type.
        // Tapping on Finish button should close the modal.
        NavigationView {
            mainView
            .searchable(text: $viewModel.searchText)
            .navigationTitle(viewModel.navTitle)
            .toolbar {
                if viewModel.selectedPaymentId != nil {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Finish") {
                            dismiss()
                        }
                    }
                }
            }
            .onAppear {
                viewModel.loadPaymentTypes()
            }.refreshable {
                viewModel.loadPaymentTypes()
            }
        }
    }
    
    private var mainView: some View {
        VStack {
            if viewModel.showLoader {
                ProgressView()
            } else {
                List {
                    ForEach(viewModel.filteredPayments) { paymentType in
                        paymentRow(payment: paymentType)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func paymentRow(payment: PaymentType) -> some View {
        Button(action: {
            viewModel.onTapPayment(id: payment.id, onComplete: { isSelected in
            })
        }, label: {
            HStack {
                Text(payment.name)
                    .foregroundColor(.black)
                
                if viewModel.isThisPaymentChecked(payment) {
                    Image(systemName: "checkmark")
                }
            }
        })
        
    }
}

// MARK: Reusable views
struct NextScreenTitleView: View {
    @State var title: String
    
    var body: some View {
        Text(title)
            .paymmentButtonStyle()
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// MARK: ViewModels

class InitialScreenViewModel: ObservableObject {
    @Published var showFinish = false
    @Published var selectedPaymentId: String?
    @Published var hideButtons = false
    
    func updateSelection(id: String?) {
        if let id = id {
            self.selectedPaymentId = id
            self.showFinish = true
        } else {
            self.selectedPaymentId = nil
            self.showFinish = false
        }
    }
    
    func timerLimitReached() {
        hideButtons = true
    }
}

class PaymentViewViewModel: ObservableObject {
    @Published var showFinish = false
    @Published var showPayment = false
    @Published var timer = 0
    @Published var showCongragulations = false
    var subscriber: AnyCancellable?
    var selectedPaymentId: String?
    
    
    func openPaymentClick() {
        self.showPayment = true
    }
    
    func updateSelection(_ isPaymentSelected: Bool) {
        self.showFinish = isPaymentSelected
    }
    
    func updateSelection(id: String?) {
        if let id = id {
            self.selectedPaymentId = id
            self.showFinish = true
        } else {
            self.selectedPaymentId = nil
            self.showFinish = false
        }
    }
    
    func finishClick() {
        showCongragulations = true
    }
}

class CountDownTimerViewModel: ObservableObject {
    
    @Published var timer: Int = 60
    private var subscriber: AnyCancellable?
    
    init() {
        self.subscribeToShowTimer()
    }
    
    func subscribeToShowTimer() {
        subscriber = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else {
                    return
                }
                self.timer = self.timer - 1
                
                if self.timer == 0 {
                    self.subscriber?.cancel()
                }
            }
    }
}

class OpenPaymentViewModel: ObservableObject {
    let buttonTitle: String = "Open Payment"
    @Published var showPayments = false
    
    func openPayment() {
        showPayments = true
    }
}

class PaymentInfoViewModel: ObservableObject {
    @Published var showLoader = false
    @Published var filteredPayments = [PaymentType]()
    @Published var selectedPaymentId: String?
    @Published var searchText: String = ""
    var originalPaymentTypes = [PaymentType]()
    private let repository: PaymentTypesRepository
    let navTitle = "Payment info"
    var subscriber: AnyCancellable?
    
    init(repository: PaymentTypesRepository = PaymentTypesRepositoryImplementation()) {
        self.repository = repository
        subscriber = $searchText.sink { [weak self] str in
            self?.onSearchClick(str)
        }
    }
    
    func onSearchClick(_ searchStr: String) {
        if searchStr.isEmpty {
            self.filteredPayments = originalPaymentTypes
        } else {
            self.filteredPayments =
            originalPaymentTypes.filter({
                let nameLowerCase = $0.name.lowercased()
                return nameLowerCase.contains(searchStr.lowercased())
            })
        }
    }
    
    func loadPaymentTypes() {
        self.showLoader = true
        self.repository.getTypes { [weak self] result in
            self?.showLoader = false
            
            switch result {
            case .success(let paymentTypes):
                self?.originalPaymentTypes = paymentTypes
                self?.filteredPayments = paymentTypes
            case .failure:
                print("handle later")
            }
        }
    }
    
    func isThisPaymentChecked(_ paymentType: PaymentType) -> Bool {
        if let selectedPaymentId = selectedPaymentId, paymentType.id == selectedPaymentId {
            return true
        }
        
        return false
    }
    
    func onTapPayment(id: String, onComplete: (Bool) -> Void) {
        if id == selectedPaymentId {
            selectedPaymentId = nil
            onComplete(false)
        } else {
            selectedPaymentId = id
            onComplete(true)
        }
    }
}

/*
 class Model: ObservableObject {
 
 let processDurationInSeconds: Int = 60
 var repository: PaymentTypesRepository = PaymentTypesRepositoryImplementation()
 var cancellables: [AnyCancellable] = []
 
 init() {
 //        Timer.publish(every: 1, on: .main, in: .common)
 //            .autoconnect()
 //            .store(in: &cancellables)
 }
 }
 */

// MARK: Common styles
extension View {
    func paymmentButtonStyle() -> some View {
        modifier(PaymmentButtonStyle())
    }
}

struct PaymmentButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(.white)
            .foregroundColor(.blue)
            .cornerRadius(10)
    }
}
