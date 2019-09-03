
/*
class A {
    static var := "old value"
    test[] {
        get => A.var
        set => A.var := value
    }

}

class B extends A {
}

global objA := new A
global objB := new B

A.var := "new value"
MsgBox(objA.test)
MsgBox(objB.test)
*/
global cont := {}
Loop 5 {
    test := {}
    test.a := "a" A_Index
    test.b := "b" A_Index
    test.c := "c" A_Index
    index := format("{1}", A_Index)
    MsgBox(index)
    cont[index] := test
}
MsgBox(cont["1"].a)

for k, v in cont {
    MsgBox(v.a "`n" v.b "`n" v.c)
}