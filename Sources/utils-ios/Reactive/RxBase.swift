//
//  RxBase.swift
//  
//
//  Created by Miroslav Yozov on 30.10.19.
//

import UIKit

import RxSwift
import RxCocoa

public class RxBaseView<M: AnyObject>: BaseView, RxModelCompatible { }

public class RxBaseTableView<M: AnyObject>: BaseTableView, RxModelCompatible { }
public class RxBaseTableViewCell<M: AnyObject>: BaseTableViewCell, RxModelCompatible { }

public class RxBaseCollectionView<M: AnyObject>: BaseCollectionView, RxModelCompatible { }
public class RxBaseCollectionViewCell<M: AnyObject>: BaseCollectionViewCell, RxModelCompatible { }

public class RxBaseViewController<M: AnyObject>: BaseViewController, RxModelCompatible { }
public class RxBaseNavigationConroller<M: AnyObject>: BaseNavigationConroller, RxModelCompatible { }
