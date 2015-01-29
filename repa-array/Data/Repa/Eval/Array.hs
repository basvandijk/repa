
module Data.Repa.Eval.Array
        ( -- * Array Targets
          Target    (..)

          -- * Array Loading
        , Load      (..)

        , computeS
        , computeSn)
where
import Data.Repa.Array.Internals.Target         as A
import Data.Repa.Array.Internals.Load           as A
import Data.Repa.Array.Internals.Bulk           as A
import Data.Repa.Array.Index                    as A
import System.IO.Unsafe
#include "repa-array.h"


-- | Sequential computation of array elements.
--
--   The destination layout is specified by the first argument.
--   If the size of the destination layout does not match the size of the
--   array then `Nothing`.
--
computeS :: Load lSrc lDst a
         => lDst -> Array lSrc a -> Maybe (Array lDst a)
computeS lDst aSrc
 | (A.size $ A.extent lDst) == A.length aSrc
 = unsafePerformIO
 $ do   buf     <- unsafeNewBuffer lDst
        loadS aSrc buf
        arr     <- unsafeFreezeBuffer buf
        return  $ Just arr

 | otherwise
 =      Nothing
{-# INLINE_ARRAY computeS #-}


-- | Like `computeS`, but use a default destination layout of the given name.
computeSn :: Load lSrc lDst a
          => Name lDst -> Array lSrc a -> Array lDst a
computeSn nDst aSrc
 = let Just aDst  = computeS (create nDst (A.length aSrc)) aSrc
   in  aDst
{-# INLINE computeSn #-}
