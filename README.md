[![Workflow Status](https://github.com/mstniy/computed_flutter/actions/workflows/tests.yml/badge.svg)](https://github.com/mstniy/computed_flutter/actions?query=branch%3Amaster+workflow%3Atests) [![codecov](https://codecov.io/github/mstniy/computed_flutter/graph/badge.svg?token=VVG1YCC1FL)](https://codecov.io/github/mstniy/computed_flutter)

Flutter bindings for [Computed](https://github.com/mstniy/computed.dart).

> [!NOTE]  
> [Computed](https://github.com/mstniy/computed.dart) has more in-depth documentation and examples about computation-based state management.

Computed Flutter allows you to interface Computed with Flutter-specific functionality, like `Widget`s and `Listenable`s.

## <a name='Tableofcontents'></a>Table of contents

<!-- vscode-markdown-toc -->

- [Here's how it works](#Hereshowitworks)
- [Using Computed with widgets](#UsingComputedwithwidgets)
  - [Using `Computed[Stateful]Widget`](#UsingComputedStatefulWidget)
  - [Using `ComputedFlutterMixin`](#UsingComputedFlutterMixin)
  - [Using `ComputedBuilder`](#UsingComputedBuilder)
- [Ingesting data sources](#Ingestingdatasources)
- [Using results of computations](#Usingresultsofcomputations)

<!-- vscode-markdown-toc-config
	numbering=false
	autoSave=true
	/vscode-markdown-toc-config -->
<!-- /vscode-markdown-toc -->

## <a name='Hereshowitworks'></a>Here's how it works

Assume you have a data source, like a `ValueListenable` representing some external state:

```
ValueListenable<int> v;
```

And you want your UI to stay in sync with this external state.  
Assume for the sake of simplicity that you want to display the value of the external state as-is.  
You can achieve this with no boilerplate using Computed:

```
Text('${v.use}')
```

Note that this does not use code generation, nor does it restrict your codebase to have at most one data source per object type.

## <a name='UsingComputedwithwidgets'></a>Using Computed with widgets

Using Computed facilities, like `.use` and `.react`, inside the `build` methods of widgets requires Computed to be aware of them.  
You can achieve this in several ways:

### <a name='UsingComputedStatefulWidget'></a>Using `Computed[Stateful]Widget`

If you have a custom widget, extending `StatelessWidget` or `StatefulWidget`, modify them to extend `ComputedWidget` or `ComputedStatefulWidget` instead:

```
class MyWidget extends ComputedWidget {
    @override
    Widget build() {
        // This effectively runs as a computation
        return Text('${v.use}'); // Automatically re-run whenever [v] changes
    }
}
```

### <a name='UsingComputedFlutterMixin'></a>Using `ComputedFlutterMixin`

If you do not want your widgets to extend `Computed[Stateful]Widget`, perhaps for widgets already extending some other class, you can use the mixin:

```
class MyWidget extends MyOtherWidget with ComputedFlutterMixin {
    ...
}
```

### <a name='UsingComputedBuilder'></a>Using `ComputedBuilder`

If you are using a widget whose definition you cannot modify, or wish to limit the scope of reactive widget rebuilds, use `ComputedBuilder`:

```
ComputedBuilder(builder: (ctx) =>
    ExternalWidget(v.use)
)
```

## <a name='Ingestingdatasources'></a>Ingesting data sources

Computed Flutter supports reactively depending on `ValueListenable`s with `.use`, as with Computed:

```
ValueListenable<int> v;

final c = $((){
    v.use; // Reactively depends on [v]
});
```

To depend on changes to `Listenable`s, you can use `.watch`:

```
class MyListenable implements Listenable {
    int get value => ...;
    ...
}

MyListenable l;

final c = $((){
    l.watch.value; // Reactively depends on [l]
});
```

## <a name='Usingresultsofcomputations'></a>Using results of computations

Computed Flutter allows you to turn computations into `Listenable`s and `ValueListenable`s:

```
final c = $(() => ...); // A computation

c.asListenable; // Returns a [ComputedListenable]
c.asValueListenable; // Returns a [ValueListenable]
```

Of course, other ways of using computations as defined by the base Computed package are available. For easy reference, this includes `.use`, `.listen` and `.asStream`.
