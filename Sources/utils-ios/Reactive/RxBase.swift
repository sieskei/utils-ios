//
//  RxBase.swift
//  
//
//  Created by Miroslav Yozov on 30.10.19.
//

import UIKit

import RxSwift
import RxCocoa

public class RxBaseView<M: Equatable>: BaseView, RxModelCompatible { }

public class RxBaseTableView<M: Equatable>: BaseTableView, RxModelCompatible { }
public class RxBaseTableViewCell<M: Equatable>: BaseTableViewCell, RxModelCompatible { }

public class RxBaseCollectionView<M: Equatable>: BaseCollectionView, RxModelCompatible { }
public class RxBaseCollectionViewCell<M: Equatable>: BaseCollectionViewCell, RxModelCompatible { }

public class RxBaseViewController<M: Equatable>: BaseViewController, RxModelCompatible { }
public class RxBaseNavigationConroller<M: Equatable>: BaseNavigationConroller, RxModelCompatible { }
