#!/usr/bin/env python3

from operator import itemgetter
from itertools import chain, count

from contextlib import suppress, contextmanager


@contextmanager
def suppress_attr(inst, attr_name, repl_name):
    attr = getattr(inst, attr_name)
    repl = getattr(inst, repl_name)
    setattr(inst, attr_name, repl)
    yield
    setattr(inst, attr_name, attr)


class Type:
    gen_type_id = count(0)

    def __init__(self):
        self.type_id = next(self.gen_type_id)

    def __str__(self):
        return "T_{self.type_id}".format(self=self)


class TypeConst(Type):
    _instances = {}

    def __new__(cls, name, *args, **kwargs):
        if name not in cls._instances:
            cls._instances[name] = super().__new__(cls, *args, **kwargs)
        return cls._instances[name]

    def __init__(self, name):
        super().__init__()
        self.name = name

    def __str__(self):
        return str(self.name)


class TypeMono(Type):  # OPTIMIZATION: zaimplementować jako las drzew rozłącznych
    gen_typemono_id = count(0)

    def __init__(self):
        super().__init__()
        self.substituted = None
        self.typemono_id = next(self.gen_typemono_id)

    def __str__(self):
        return "τ_{self.typemono_id}".format(self=self)

    def union(self, x):
        if self.typemono_id == x.typemono_id:
            return
        if self.substituted:
            return self.substituted.union(x)
        if isinstance(x, Type):
            self.substituted = x


# --------------------------------------------------------------------------------


class Record:
    def __init__(self, fields=None, rest=None, parents=None):
        self.fields = fields or {}
        self.rest = rest or Lacks()
        self.parents = parents or []
        self.children = []
        for f in fields:
            self.rest.add_lacks(f)

    def __getitem__(self, item):
        return self.fields[item]

    # noinspection PyUnreachableCode
    def selection(self, label):
        with suppress(KeyError):
            return self[label]
        self.extend(label, TypeMono())

    def restrict(self, label):  # TODO… ale czy na pewno potrzebne?
        raise NotImplementedError()

    def reduce_tailvariant(self):
        with suppress(TypeError):  # when set.intersection gets no args
            common = set.intersection(*(var for var in self.rest))
            if common:
                print(str(common))
                raise NotImplementedError

    def nop(self, *args, **kwargs):
        pass

    def extend(self, l, t):
        if l in self.fields:
            return self.fields[l].union(t)
        self.rest.add_lacks(l)  # TODO: ma też usuwać jeśli pole ew. istnieje
        self.fields[l] = t

        with suppress_attr(self, "extend", "nop"):  # symulacja czegoś w stylu kolorowania w DFS -- by uniknąć nieskończonej rekursji
            pass
            # for c in self.children:
            #     print("NORMALIZING CHILD", c)
            #     c.extend(l, t)
            #     c.reduce_tailvariant()  # TODO: znajduje wspólne elementy, wyciąga
                # self.rest.restrict(l)  # TODO: chyba nie trzeba skoro i tak jest rekursja?
            # for c in self.parents:
            #     print("NORMALIZING PARENT", c)
                # c.extend(l, t) # nie tak, zbyt mocne. rozszerz tylko swój variant
                # c.reduce_tailvariant()  # TODO: znajduje wspólne elementy, wyciąga

    def __str__(self):
        fields = ", ".join("{0}::{1}".format(k, v)
                           for k, v
                           in sorted(self.fields.items(), key=itemgetter(0)))
        rest = ""
        if self.rest:
            rest = " | " + str(self.rest)
        return "R{{{0}{1}}}".format(fields, rest)

    def lacks(self):  # może zwracać powtórzenia
        deep_flds = set(self)
        for lack in self.rest.lacks():
            if lack not in deep_flds:
                yield lack

    def add_lacks(self, l):
        with suppress(KeyError):
            del self.fields[l]
        self.rest.add_lacks(l)

    def __iter__(self):
        yield from self.fields
        yield from self.rest

    def normalized(self):
        # czy z przodu wszystko jest podtypem Type
        if any(not isinstance(t, Type)
               for t in self.fields.values()):
            return False

        # TODO: czy lacks się zgadzają
        deep_lacks = list(self.lacks())
        for fld in self.fields:
            if fld not in deep_lacks:
                return False, fld, list(self.lacks())

        # czy nie ma czegoś co jest z tyłu a powinno być z przodu
        if any(all(fld in list(var)  # jeżeli jakikolwiek atrybut jest wspólny dla wszystkich tail-wariantów
                   for var in self.rest)
               for alt in self.rest
               for fld in alt):
            return False
        # wszystko git
        return True

    def union(self, rec_b):
        common_keys = self.fields.keys() & rec_b.fields.keys()
        var_a = Record(fields={k: self.fields[k] for k in self.fields.keys() - common_keys})
        var_b = Record(fields={k: rec_b.fields[k] for k in rec_b.fields.keys() - common_keys})
        res = Record(fields={k: self.fields[k] for k in common_keys},
                     rest=Variant(var_a, var_b),
                     parents=[self, rec_b])
        self.children.append(res)
        rec_b.children.append(res)
        return res


class Lacks:
    def __init__(self, *args):
        self.args = list(args)  # TODO dict

    def lacks(self):
        yield from self.args

    def __iter__(self):
        yield from ()

    def __str__(self):
        return "r{0}".format(" ".join("⑊" + str(x) for x in sorted(self.args)))

    def __bool__(self):
        return self.lacks and True or False

    def add_lacks(self, l):
        self.args.append(l)


class Variant:
    def __init__(self, *args):
        self.alternatives = args

    def __str__(self):
        return "V({0})".format(", ".join(str(x) for x in self.alternatives))

    def __iter__(self):
        for alt in self.alternatives:
            yield from alt

    # noinspection PyMethodMayBeStatic
    def lacks(self):
        lck = [set(x.lacks()) for x in self.alternatives]
        yield from list(set.intersection(*lck))  # a może union?

    def add_lacks(self, l):
        for alt in self.alternatives:
            alt.add_lacks(l)


# --------------------------------------------------------------------------------


def main():
    a = Record(fields={'x': TypeConst('Int'),
                       'y': TypeMono()})
    b = Record(fields={'x': TypeMono(),
                       'z': TypeMono()})
    print("#### UNION ####")
    c = a.union(b)

    # c.selection('m')
    print("#### a.selection('p') ####")
    a.selection('p')
    # print("#### b.selection('p') ####")
    # b.selection('p')
    
    c_v1 = c.rest.alternatives[0]
    c_v2 = c.rest.alternatives[1]
    print("a = {a}"
          "\n    normalized: {0}"
          "\n    lacks:      {1}"
          .format(a.normalized(), ", ".join(a.lacks()) or '--', **locals()))
    print("b = {b}"
          "\n    normalized: {0}"
          "\n    lacks:      {1}"
          .format(b.normalized(), ", ".join(b.lacks()) or '--', **locals()))
    print("c = {c}"
          "\n    normalized: {0}"
          "\n    lacks:      {1}"
          .format(c.normalized(), ", ".join(c.lacks()) or '--', **locals()))
    print("--------------------------------------------------------------------------------")
    print("c var2 = {c_v1}"
          "\n    normalized: {0}"
          "\n    lacks:      {1}"
          .format(c_v1.normalized(), ", ".join(c_v1.lacks()) or '--', **locals()))
    print("c var2 = {c_v2}"
          "\n    normalized: {0}"
          "\n    lacks:      {1}"
          .format(c_v2.normalized(), ", ".join(c_v2.lacks()) or '--', **locals()))


if __name__ == '__main__':
    main()