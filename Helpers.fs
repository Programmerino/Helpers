module Helpers

open System
open FSharp.Control.Reactive
open FSharpPlus

let (=>) x y = (not x) || y

module Extensions =
    [<RequireQualifiedAccess>]
    module Option =
        let log (msg: obj) (x: 'a option) : 'a option =
            match x with
            | Some _ -> x
            | None ->
                Console.WriteLine(msg)
                x

        let asserttap (cond: 'a -> bool) (x: 'a) : 'a option =
            match (cond x) with
            | true -> Some(x)
            | false -> None

        let assertion (cond: bool) : Unit option = asserttap (konst cond) ()

let log x = printfn $"###{x}"

let inline expandObservable x =
    match x with
    | Some x -> x |> Observable.map Some
    | None -> Observable.single None

let inline convertPrice x =
    x
    |> String.replace "$" ""
    |> String.replace "From" ""
    |> String.replace "," ""
    |> String.replace " " ""
    |> Result.protect decimal
    |> Result.mapError (fun y -> Exception($"{x} ") ++ y)

let inline csv x =
    x
    |> map (String.replace "," ";")
    |> String.intercalate ","

let inline optBisequence x =
    match x with
    | (Ok x), (Ok y) -> Ok(x, y)
    | (Error e), (Ok y) -> Error e
    | (Ok x), (Error e) -> Error e
    | (Error e), (Error f) -> Error e

let inline expandObservableOpt x =
    match x with
    | Some x -> x |> Observable.map Some
    | None -> Observable.single None

let inline expandObservableRes (x: Result<IObservable<'a>, 'b>) =
    match x with
    | Ok y -> y |> Observable.map Ok
    | Error y -> Observable.single (Error y)
