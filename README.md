# CycleScrollView

```
    func numberOfPages(in cycleScrollView: CycleScrollView) -> Int {
        return viewData.count
    }
    
    func cycleScrollView(_ cycleScrollView: CycleScrollView, viewForPageAt index: Int) -> UIView {
        return viewData[index]
    }
    
    func cycleScrollView(_ cycleScrollView: CycleScrollView, didSelectPageAt index: Int) {
        print(index)
    }
```
