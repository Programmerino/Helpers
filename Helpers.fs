module Helpers

open System
open FSharp.Control.Reactive
open FSharpPlus

module Logic =
    let (=>) x y = (not x) || y

module ArgumentParsing =
    let programName baseName =
        match Environment.OSVersion.Platform with
        | PlatformID.Win32NT
        | PlatformID.Win32S
        | PlatformID.Win32Windows
        | PlatformID.WinCE
        | PlatformID.Xbox -> baseName ++ ".exe"
        | PlatformID.Unix
        | PlatformID.MacOSX
        | PlatformID.Other
        | _ -> baseName

module Extensions =
    open FSharpPlus.Data

    [<RequireQualifiedAccess>]
    module Option =
        let inline wlog msg x =
            monad {
                match x with
                | Some _ -> x
                | None ->
                    Writer.tell msg
                    x
            }

        let log (msg: obj) (x: 'a option) : 'a option = wlog msg x |> Writer.exec

        let asserttap (cond: 'a -> bool) (x: 'a) : 'a option =
            match (cond x) with
            | true -> Some(x)
            | false -> None

        let assertion (cond: bool) : Unit option = asserttap (konst cond) ()

    [<RequireQualifiedAccess>]
    module String =
        let inline toCSVString x =
            x
            |> map (String.replace "," ";")
            |> String.intercalate ","

    [<RequireQualifiedAccess>]
    module Decimal =
        let fromPriceString x =
            x
            |> String.replace "$" ""
            |> String.replace "From" ""
            |> String.replace "," ""
            |> String.replace " " ""
            |> Result.protect decimal
            |> Result.mapError (fun y -> Exception($"{x} ") ++ y)

    [<RequireQualifiedAccess>]
    module Observable =
        let ofOption x =
            match x with
            | Some x -> x |> Observable.map Some
            | None -> Observable.single None

    [<RequireQualifiedAccess>]
    module Result =
        let bisequence x =
            match x with
            | (Ok x), (Ok y) -> Ok(x, y)
            | (Error e), (Ok _) -> Error e
            | (Ok _), (Error e) -> Error e
            | (Error e), (Error _) -> Error e

let expandObservableFstRes (x: Result<IObservable<'a>, 'b>) =
    match x with
    | Ok y -> y |> Observable.map Ok
    | Error y -> Observable.single (Error y)
