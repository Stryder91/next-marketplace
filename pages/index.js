import { useEffect, useState } from 'react'
import { ethers } from 'ethers'
import styles from '../styles/Home.module.css'
import axios from 'axios'
import Web3Modal from 'web3modal'

import NFT from '../artifacts/contracts/NFT.sol/NFT.json'
import Market from '../artifacts/contracts/NFTMarket.sol/NFTMarket.json'

export default function Home() {

  const [nfts, setNfts] = useState([]);
  const [loading, setLoading] = useState('not-loaded');
  

  useEffect(() => {
    loadNFTs();
  }, [])
  async function loadNFTs() {
    
  }

  return (
    <div className={styles.container}>
      <h1>Home</h1>
    </div>
  )
}
