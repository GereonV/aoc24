import Data.Map.Strict qualified as M

countCollect :: (Ord a) => [a] -> M.Map a Int
countCollect = foldl' (\m x -> M.insertWith (+) x 1 m) M.empty

rmLeadingZeros :: String -> String
rmLeadingZeros s = case dropWhile (== '0') s of
  "" -> "0"
  r -> r

blink :: String -> [String]
blink x
  | x == "0" = ["1"]
  | length x `mod` 2 == 0 = let s = length x `div` 2 in rmLeadingZeros <$> [take s x, drop s x]
  | otherwise = [show $ read x * 2024]

solve :: Int -> M.Map String Int -> Int
solve = go M.empty
  where
    go _ 0 counts = M.foldl' (+) 0 counts
    go cache n counts = let (nCache, nCounts) = foldl' comb (cache, M.empty) $ M.assocs counts in go nCache (n - 1) nCounts
    comb ~(cache, counts) ~(x, nx) = (nCache, foldl' (\c x -> M.insertWith (+) x nx c) counts l)
      where
        ~(nCache, l) = case cache M.!? x of
          Just l -> (cache, l)
          Nothing -> let l = blink x in (M.insert x l cache, l)

main :: IO ()
main = interact $ unlines . map show . zipWith solve [25, 75] . repeat . countCollect . words
