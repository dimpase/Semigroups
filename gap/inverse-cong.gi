############################################################################
##
#W  inverse-cong.gi
#Y  Copyright (C) 2015                                   Michael C. Torpey
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##
## This file contains methods for congruences on inverse semigroups, using the
## "kernel and trace" representation.
##

InstallGlobalFunction(InverseSemigroupCongruenceByKernelTrace,
[IsInverseSemigroup and IsFinite, IsInverseSemigroup, IsDenseList],
function(s, kernel, traceBlocks)
  local a, x, traceClass, f, l, e;
  # Check that the kernel is an inverse subsemigroup
  if not IsInverseSubsemigroup(s, kernel) then
    Error("Semigroups: InverseSemigroupCongruenceByKernelTrace: usage,\n",
          "the second arg <kernel> must be an inverse subsemigroup of the\n",
          "first arg <S>,");
    return;
  fi;
  # CHECK KERNEL IS NORMAL:
  # (1) Must contain all the idempotents of s
  if NrIdempotents(kernel) <> NrIdempotents(s) then
    Error("Semigroups: InverseSemigroupCongruenceByKernelTrace: usage,\n",
          "the second arg <kernel> must contain all the idempotents of the\n",
          "first arg <S>,");
    return;
  fi;
  # (2) Must be self-conjugate
  for a in kernel do
    for x in GeneratorsOfSemigroup(s) do
      if not a ^ x in kernel then
  Error("Semigroups: InverseSemigroupCongruenceByKernelTrace: usage,\n",
        "the second arg <kernel> must be self-conjugate,");
        return;
      fi;
    od;
  od;
  # Check conditions for a congruence pair: Howie p.156
  for traceClass in traceBlocks do
    for f in traceClass do
      l := LClass(s,f);
      for a in l do
        if a in kernel then
          # Condition (C2): aa' related to a'a
          if not a * a ^ - 1 in traceClass then
            Error("Semigroups: InverseSemigroupCongruenceByKernelTrace:\n",
                  "not a valid congruence pair,");
            return;
          fi;
        else
          # Condition (C1): (ae in kernel && e related to a'a) => a in kernel
          for e in traceClass do
            if a * e in kernel then
              Error("Semigroups: InverseSemigroupCongruenceByKernelTrace:\n",
                    "not a valid congruence pair,");
              return;
            fi;
          od;
        fi;
      od;
    od;
  od;
  return InverseSemigroupCongruenceByKernelTraceNC(s, kernel, traceBlocks);
end);

#

InstallGlobalFunction(InverseSemigroupCongruenceByKernelTraceNC,
[IsInverseSemigroup and IsFinite, IsSemigroup, IsDenseList],
function(s, kernel, traceBlocks)
  local traceLookup, i, elm, fam, cong;
  # Calculate lookup table for trace
  # Might remove lookup - might never be better than blocks
  traceLookup := [];
  for i in [1 .. Length(traceBlocks)] do
    for elm in traceBlocks[i] do
      traceLookup[Position(Idempotents(s),elm)] := i;
    od;
  od;
  # Construct the object
  fam := GeneralMappingsFamily(
                 ElementsFamily(FamilyObj(s)),
                 ElementsFamily(FamilyObj(s)) );
  cong := Objectify(
                  NewType(fam, IsInverseSemigroupCongruenceByKernelTrace),
                  rec(kernel := kernel,
                      traceBlocks := traceBlocks,
                      traceLookup := traceLookup) );
  SetSource(cong, s);
  SetRange(cong, s);
  return cong;
end);

#

InstallMethod(ViewObj,
"for inverse semigroup congruence",
[IsInverseSemigroupCongruenceByKernelTrace],
function(cong)
  Print("<semigroup congruence over ");
  ViewObj(Range(cong));
  Print(" with congruence pair (",
        Size(cong!.kernel), ",",
        Size(cong!.traceBlocks),")>");
end);

#

InstallMethod(\=,
"for two inverse semigroup congruences",
[IsInverseSemigroupCongruenceByKernelTrace,
IsInverseSemigroupCongruenceByKernelTrace],
function(cong1, cong2)
  return(Range(cong1) = Range(cong2) and
         cong1!.kernel = cong2!.kernel and
         cong1!.traceBlocks = cong2!.traceBlocks);
end);

#

InstallMethod(ImagesElm,
"for inverse semigroup congruence and associative element",
[IsInverseSemigroupCongruenceByKernelTrace, IsAssociativeElement],
function(cong, elm)
  local s, images, e, b;
  s := Range(cong);
  if not elm in s then
    Error("Semigroups: ImagesElm: usage,\n",
          "the first arg <cong> is not defined over the semigroup of the",
          "second\nargument <elm>,");
    return;
  fi;
  images := [];
  # Consider all idempotents trace-related to (a^-1 a)
  for e in First(cong!.traceBlocks, c -> (elm ^ - 1 * elm) in c) do
    for b in LClass(s,e) do
      if elm * b ^ - 1 in cong!.kernel then
        Add(images, b);
      fi;
    od;
  od;
  return images;
end);

#

InstallMethod(\in,
"for dense list and inverse semigroup congruence",
[IsDenseList, IsInverseSemigroupCongruenceByKernelTrace],
function(pair, cong)
  local s;
  if Size(pair) <> 2 then
    Error("Semigroups: \in: usage,\n",
          "the first arg <pair> must be a list of length 2,");
    return;
  fi;
  s := Range(cong);
  if not (pair[1] in s and pair[2] in s) then
    Error("Semigroups: \in: usage,\n",
          "the entries of the first arg <pair> must belong to the semigroup",
          " of <cong>,");
    return;
  fi;
  # Is (a^-1 a, b^-1 b) in the trace?
  if pair[1] ^ - 1 * pair[1] in
     First(cong!.traceBlocks, c -> pair[2] ^ - 1 * pair[2] in c) then
    # Is ab^-1 in the kernel?
    if pair[1] * pair[2] ^ - 1 in cong!.kernel then
      return true;
    fi;
  fi;
  return false;
end);

#

InstallMethod(EquivalenceClassOfElement,
"for inverse semigroup congruence and associative element",
[IsInverseSemigroupCongruenceByKernelTrace, IsAssociativeElement],
function(cong, elm)
  if not elm in Range(cong) then
    Error("Semigroups: EquivalenceClassOfElement: usage,\n",
    "the second arg <elm> must be in the semigroup of the first arg <cong>,");
    return;
  fi;
  return EquivalenceClassOfElementNC(cong, elm);
end);

#

InstallMethod(EquivalenceClassOfElementNC,
"for inverse semigroup congruence and associative element",
[IsInverseSemigroupCongruenceByKernelTrace, IsAssociativeElement],
function(cong, elm)
  local fam, class;
  fam := FamilyObj(Range(cong));
  class := Objectify(NewType(fam, IsInverseSemigroupCongruenceClassByKernelTrace),
                   rec(rep := elm) );
  SetParentAttr(class, cong);
  SetRepresentative(class, elm);
  return class;
end);

#

InstallMethod(\=,
"for two inverse semigroup congruence classes",
[IsInverseSemigroupCongruenceClassByKernelTrace,
IsInverseSemigroupCongruenceClassByKernelTrace],
function(c1, c2)
  return( ParentAttr(c1) = ParentAttr(c2) and
          [c1!.rep, c2!.rep] in ParentAttr(c1) );
end);

#

InstallMethod( \in,
"for associative element and inverse semigroup congruence class",
[IsAssociativeElement, IsInverseSemigroupCongruenceClassByKernelTrace],
function(elm, class)
  local cong;
  cong := ParentAttr(class);
  return elm in Range(cong) and [elm, class!.rep] in cong;
end);

#

InstallMethod( \*,
"for two inverse semigroup congruence classes",
[IsInverseSemigroupCongruenceClassByKernelTrace,
IsInverseSemigroupCongruenceClassByKernelTrace],
function(c1, c2)
  if not Parent(c1) = Parent(c2) then
    Error("Semigroups: \*: usage,\n",
          "the arguments must be classes of the same congruence,");
    return;
  fi;
  return EquivalenceClassOfElementNC(Parent(c1), c1!.rep * c2!.rep);
end);

#

InstallMethod(AsSSortedList,
"for inverse semigroup congruence class",
[IsInverseSemigroupCongruenceClassByKernelTrace],
function(class)
  return SSortedList(ImagesElm(ParentAttr(class), class!.rep));
end);

#

InstallMethod(Size,
"for inverse semigroup congruence class",
[IsInverseSemigroupCongruenceClassByKernelTrace],
function(class)
  return Size(Elements(class));
end);

#

InstallMethod(TraceOfSemigroupCongruence,
"for semigroup congruence",
[IsSemigroupCongruence],
function(cong)
  local s, elms, trace, i, class, congClass, j;
  s := Range(cong);
  if not IsInverseSemigroup(s) then
    Error("Semigroups: TraceOfSemigroupCongruence: usage,\n",
          "the argument <cong> must be over an inverse semigroup,");
    return;
  fi;
  elms := ShallowCopy(Idempotents(s));
  trace := [];
  for i in [1 .. Size(elms)] do
    if elms[i] <> fail then
      class := [ elms[i] ];
      congClass := EquivalenceClassOfElementNC(cong, elms[i]);
      for j in [i + 1 .. Size(elms)] do
        if elms[j] in congClass then
          Add(class, elms[j]);
          elms[j] := fail;
        fi;
      od;
      Add(trace, class);
    fi;
  od;
  return trace;
end);

#

InstallMethod(KernelOfSemigroupCongruence,
"for semigroup congruence",
[IsSemigroupCongruence],
function(cong)
  local s, gens;
  s := Range(cong);
  if not IsInverseSemigroup(s) then
    Error("Semigroups: KernelOfSemigroupCongruence: usage,\n",
          "the first arg <cong> must be over an inverse semigroup,");
    return;
  fi;
  gens := Union(List(Idempotents(s), e -> EquivalenceClassOfElementNC(cong,e)));
  return InverseSemigroup(gens, rec(small := true) );
end);

#

InstallMethod(AsInverseSemigroupCongruenceByKernelTrace,
"for semigroup congruence with generating pairs",
[IsSemigroupCongruence and HasGeneratingPairsOfMagmaCongruence],
function(cong)
  local s, idsmgp, ids, pos, hashlen, ht, treehashsize, right, left, find, 
        union, enumerate_trace, enforce_conditions, compute_kernel, genpairs, 
        pairstoapply, nr, traceLookup, kernel, kernelgenstoapply, oldLookup, 
        oldKernel, traceBlocks;
  # Check that the argument makes sense
  s := Range(cong);
  if not IsInverseSemigroup(s) then
    Error("Semigroups: AsInverseSemigroupCongruenceByKernelTrace: usage,\n",
          "the argument <cong> must be over an inverse semigroup,");
    return;
  fi;
  
  # Setup some data structures for the trace
  idsmgp := IdempotentGeneratedSubsemigroup(s);
  ids := Elements(idsmgp);
  pos := 0;
  if IsBound(s!.opts) then
    hashlen := s!.opts.hashlen.L;
  else
    hashlen := SemigroupsOptionsRec.hashlen.L;
  fi;
  ht := HTCreate( [ids[1],ids[1]], rec(forflatplainlists := true,
              treehashsize := hashlen ) );
  
  right := RightCayleyGraphSemigroup(idsmgp);
  left := LeftCayleyGraphSemigroup(idsmgp);
  
  find := function(i)
    while traceLookup[i] <> i do
      i := traceLookup[i];
    od;
    return i;
  end;

  union := function(pair)
    local ii, jj;
    ii := find(pair[1]);
    jj := find(pair[2]);
    if ii < jj then
      traceLookup[jj] := ii;
    elif jj < ii then
      traceLookup[ii] := jj;
    fi;
  end;
  
  # STEPS (2)+(1)
  enumerate_trace := function()
    local x, a, y, j;
    if pos = 0 then
      # Add the generating pairs themselves
      for x in pairstoapply do
        if x[1] <> x[2] and HTValue(ht, x) = fail then
          HTAdd(ht, x, true);
          union(x);
          # Add each pair's "conjugate" pairs
          for a in GeneratorsOfSemigroup(s) do
            nr := nr + 1;
            y := [Position(ids, a^-1 * ids[x[1]] * a),
                  Position(ids, a^-1 * ids[x[2]] * a)];
            if y[1] <> y[2] and HTValue(ht, y) = fail then
              HTAdd(ht, y, true);
              nr := nr + 1;
              pairstoapply[nr] := y;
              union(y);
            fi;
          od;
        fi;
      od;
    fi;

    while pos < nr do
      pos := pos + 1;
      x := pairstoapply[pos];
      for j in genstoapply do
        # Add the pair's left-multiples
        y := [right[x[1]][j], right[x[2]][j]];
        if y[1] <> y[2] and HTValue(ht, y) = fail then
          HTAdd(ht, y, true);
          nr := nr + 1;
          pairstoapply[nr] := y;
          union(y);
        fi;

        # Add the pair's right-multiples
        y := [left[x[1]][j], left[x[2]][j]];
        if y[1] <> y[2] and HTValue(ht, y) = fail then
          HTAdd(ht, y, true);
          nr := nr + 1;
          pairstoapply[nr] := y;
          union(y);
        fi;
      od;
    od;
    traceLookup := List(traceLookup, find);
  end;

  # STEPS (6)+(5)
  enforce_conditions := function()
    for a in s do
      if a in kernel then
        e := Position(ids, LeftOne(a));
        f := Position(ids,RightOne(a));
        if find(e) <> find(f) then
          nr := nr + 1;
          pairstoapply[nr] := [e,f];
        fi;
      else
        fclass := find(Position(ids, RightOne(a)));
        for e in [1 .. Length(traceLookup)] do
          if (find(e) = fclass) and (a*ids[e] in kernel) then
            put_in_kernel(a);
          fi;
        od;
      fi;
    od;
  end;
  
  # STEPS (3)+(4)
  compute_kernel := function()
    local nr;
    nr := Length(kernelgenstoapply);
    while nr > 0 do
      # Take the inverse semigroup containing the new elements
      kernel := ClosureInverseSemigroup(kernel, kernelgenstoapply);
      kernelgenstoapply := [];
      nr := 0;
      # Take the normal closure
      for a in GeneratorsOfSemigroup(s) do
        for n in kernel do
          x := n ^ a;
          if not x in kernel then
            nr := nr + 1;
            kernelgenstoapply[nr] := x;
          fi;
        od;
      od;
    od;
    kernel := InverseSemigroup(kernel, rec(small:=true));
  end;
  
  # Retrieve the initial information
  genpairs := GeneratingPairsOfSemigroupCongruence(cong);
  pairstoapply := List(pairs, x -> [Position(elms, RightOne(x[1])),
                                    Position(elms, RightOne(x[2]))] );
  nr := Length(pairstoapply);
  traceLookup := [1 .. Length(ids)];
  kernel := IdempotentGeneratedSubsemigroup(s);
  kernelgenstoapply := List(pairs, x -> x[1] * x[2]^-1);
  
  # Keep applying the method until no new info is found
  repeat
    oldLookup := traceLookup;
    oldKernel := kernel;
    compute_kernel();
    enforce_conditions();
    enumerate_trace();
  until (oldLookup = traceLookup) and (oldKernel = kernel);
  
  # Convert traceLookup to traceBlocks
  traceBlocks := Set(List([1 .. Maximum(traceLookup)],
                         i-> List(Positions(traceLookup, i), 
                                 j-> ids[j])));
  
  return InverseSemigroupCongruenceByKernelTraceNC(s, kernel, traceBlocks);
end);

#

InstallGlobalFunction(SEMIGROUPS_InverseCongFromPairs,
function(s, pairs)
  local cong;
  cong := AsInverseSemigroupCongruenceByKernelTrace(
                  SemigroupCongruenceByGeneratingPairs(s, pairs) );
  SetGeneratingPairsOfMagmaCongruence(cong, pairs);
  return cong;
end);

#
