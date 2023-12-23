[![Workflow Status](https://github.com/mstniy/computed_flutter/actions/workflows/tests.yml/badge.svg)](https://github.com/mstniy/computed_flutter/actions?query=branch%3Amaster+workflow%3Atests) [![codecov](https://codecov.io/github/mstniy/computed_flutter/graph/badge.svg?token=VVG1YCC1FL)](https://codecov.io/github/mstniy/computed_flutter)

Flutter bindings for [Computed](https://github.com/mstniy/computed.dart).

> [!NOTE]  
> [Computed](https://github.com/mstniy/computed.dart) has more in-depth documentation and examples about computation-based state management.

Computed Flutter allows you to interface Computed with Flutter-specific functionality, like `Widget`s and `Listenable`s.

## <a name='table-of-contents'></a>Table of contents

<!-- vscode-markdown-toc -->

- [Here is how it works](#here-is-how-it-works)
- [Using Computed with widgets](#using-computed-with-widgets)
  - [Using `Computed[Stateful]Widget`](#using-`computed[stateful]widget`)
  - [Using `ComputedFlutter[Stateful]Mixin`](#using-`computedflutter[stateful]mixin`)
  - [Using `ComputedBuilder`](#using-`computedbuilder`)
- [Ingesting data sources](#ingesting-data-sources)
- [Using results of computations](#using-results-of-computations)

<!-- vscode-markdown-toc-config
	numbering=false
	autoSave=true
	/vscode-markdown-toc-config -->
<!-- /vscode-markdown-toc -->

## <a name='here-is-how-it-works'></a>Here is how it works

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

## <a name='using-computed-with-widgets'></a>Using Computed with widgets

Using Computed facilities, like `.use` and `.react`, inside the `build` methods of widgets requires Computed to be aware of them.  
You can achieve this in several ways:

### <a name='using-`computed[stateful]widget`'></a>Using `Computed[Stateful]Widget`

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

### <a name='using-`computedflutter[stateful]mixin`'></a>Using `ComputedFlutter[Stateful]Mixin`

If you do not want your widgets to extend `Computed[Stateful]Widget`, perhaps for widgets already extending some other class, you can use the mixins:

```
class MyWidget extends MyOtherWidget with ComputedFlutterMixin {
    ...
}

class MyStatefulWidget extends MyOtherStatefulWidget with ComputedFlutterStatefulMixin {
    ...
}
```

### <a name='using-`computedbuilder`'></a>Using `ComputedBuilder`

If you are using a widget whose definition you cannot modify, or wish to limit the scope of reactive widget rebuilds, use `ComputedBuilder`:

```
ComputedBuilder(builder: (ctx) =>
    ExternalWidget(v.use)
)
```

## <a name='ingesting-data-sources'></a>Ingesting data sources

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

## <a name='using-results-of-computations'></a>Using results of computations

Computed Flutter allows you to turn computations into `Listenable`s and `ValueListenable`s:

```
final c = $(() => ...); // A computation

c.asListenable; // Returns a [ComputedListenable]
c.asValueListenable; // Returns a [ValueListenable]
```

Of course, other ways of using computations as defined by the base Computed package are available. For easy reference, this includes `.use`, `.listen` and `.asStream`.
