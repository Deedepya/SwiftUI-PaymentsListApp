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

// MARK: Constants
enum Constants {
    enum UI {
        static let finish = "Finish"
        static let openPayment = "Open Payment"
        static let congragulations = "Congratulations"
        static let done = "Done"
        static let paymentInfo = "Payment info"
    }
    
    enum Defaults {
        static let timeLimit = 60
    }
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
        let test = Self._printChanges()
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
            
            OpenPaymentView(content: {
                PaymentModalView(onDoneClick: {
                    viewModel.onDoneClick()
                })
            })
        
            if viewModel.showFinish {
                FinishView()
            }
        }
        .padding(10)
    }
}

struct CountDownTimerView: View {
    @StateObject private var viewModel = CountDownTimerViewModel()

    var body: some View {
        // let test = Self._printChanges()
        VStack(alignment: .center) {

            Text("You have only \(viewModel.timer) seconds left to get the discount")
                .font(.title)
                .bold()
                .foregroundColor(.white)
        }
        .background(.blue)
    }
}

struct OpenPaymentView<ModalView: View>: View {
    @StateObject private var viewModel = OpenPaymentViewModel()
    let content: () -> ModalView
    
    var body: some View {
        let test = Self._printChanges()
        Button {
            viewModel.openPayment()
        } label: {
            NextScreenTitleView(title: viewModel.buttonTitle)
        }
        .sheet(isPresented: $viewModel.showPayments) {
            content()
        }
    }
}

//struct OpenPaymentView: View {
//    @StateObject private var viewModel = OpenPaymentViewModel()
//
//    var body: some View {
//        let test = Self._printChanges()
//        Button {
//            viewModel.openPayment()
//        } label: {
//            NextScreenTitleView(title: viewModel.buttonTitle)
//        }
//        .sheet(isPresented: $viewModel.showPayments) {
//            PaymentModalView()
//        }
//    }
//}

struct FinishView: View {
    var body: some View {
        let test = Self._printChanges()
        NavigationLink(destination: CongratulationsView()) {
            NextScreenTitleView(title: Constants.UI.finish)
        }
    }
}

struct CongratulationsView: View {
    var body: some View {
        let test = Self._printChanges()
        Text(Constants.UI.congragulations)
    }
}

struct PaymentModalView: View {
    @StateObject var viewModel = PaymentInfoViewModel()
    @Environment(\.dismiss) private var dismiss
    let onDoneClick: () -> Void
    
    var body: some View {
        let test = Self._printChanges()
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
                if viewModel.isPaymentSelected {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(Constants.UI.done) {
                            onDoneClick()
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
    func paymentRow(payment: PaymentRowViewModel) -> some View {
        PaymentTypeRowView(viewModel: payment, onSelect: { id, isChecked in
            viewModel.onTapPayment(id: id, isChecked: isChecked)
        })
    }
}

struct PaymentTypeRowView: View, Equatable {
    static func == (lhs: PaymentTypeRowView, rhs: PaymentTypeRowView) -> Bool {
        lhs.viewModel.isSelected == rhs.viewModel.isSelected
    }
    
    @ObservedObject var viewModel: PaymentRowViewModel
    let onSelect: (String, Bool) -> Void
    
    var body: some View {
        let test = Self._printChanges()
        Button(action: {
            viewModel.handleSelection(onComplete: onSelect)
        }, label: {
            HStack {
                Text(viewModel.payment.name)
                    .foregroundColor(.black)
                
                if viewModel.isSelected {
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
        let test = Self._printChanges()
        Text(title)
            .paymmentButtonStyle()
    }
}


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

// MARK: Previews
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// MARK: ViewModels

class InitialScreenViewModel: ObservableObject {
    @Published var showFinish = false
 
    func onDoneClick() {
        showFinish = true
    }
}

class CountDownTimerViewModel: ObservableObject {
    
    @Published var timer: Int = Constants.Defaults.timeLimit
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
    let buttonTitle: String = Constants.UI.openPayment
    @Published var showPayments = false
    
    func openPayment() {
        showPayments = true
    }
}

class PaymentInfoViewModel: ObservableObject {
    @Published var showLoader = false
    @Published var filteredPayments = [PaymentRowViewModel]()
    @Published var isPaymentSelected: Bool = false
    @Published var searchText: String = "" {
        didSet {
            onSearchClick()
        }
    }
    
    let navTitle = Constants.UI.paymentInfo
    private var originalPaymentTypes = [PaymentRowViewModel]()
    private let repository: PaymentTypesRepository
    
    init(repository: PaymentTypesRepository = PaymentTypesRepositoryImplementation()) {
        self.repository = repository
    }
    
    func loadPaymentTypes() {
        self.showLoader = true
        self.repository.getTypes { [weak self] result in
            self?.showLoader = false
            
            switch result {
            case .success(let paymentTypes):
                let paymentRowViewModels = paymentTypes.map {
                    PaymentRowViewModel(payment: $0)
                }
                
                self?.originalPaymentTypes = paymentRowViewModels
                self?.filteredPayments = paymentRowViewModels
            case .failure:
                print("handle later")
            }
        }
    }
    
    func onTapPayment(id: String = "", isChecked: Bool) {
        
        if isChecked {
            // Find index of previously selected item
            if let previousIndex = originalPaymentTypes.firstIndex(where: { $0.isSelected && $0.payment.id != id }) {
                originalPaymentTypes[previousIndex].isSelected = false
            }
        }
        
        updateIsSelected(isChecked)
    }
    
    private func updateIsSelected(_ isSelected: Bool) {
        if isPaymentSelected != isSelected {
            isPaymentSelected = isSelected
        }
    }
    
    private func onSearchClick() {
        let search = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        filteredPayments = search.isEmpty ? originalPaymentTypes: originalPaymentTypes.filter {
            $0.payment.name.lowercased().contains(search)
        }
    }
    
}


class PaymentRowViewModel: ObservableObject, Identifiable {
    let payment: PaymentType
    @Published var isSelected = false
    
    init(payment: PaymentType, isSelected: Bool = false) {
        self.payment = payment
        self.isSelected = isSelected
    }
        
    func handleSelection(onComplete: @escaping (String, Bool) -> Void) {
        self.isSelected = !self.isSelected
        onComplete(payment.id, self.isSelected)
    }
}

