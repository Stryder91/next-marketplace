import { useState } from "react";
import { ethers } from "ethers";
import { create as ipfsHttpClient } from "ipfs-http-client";
import { useRouter } from 'next/router';
import Web3Modal from 'web3modal';

const client = ipfsHttpClient('https://ipfs.infura.io:5001/api/v0');

import { nftAddress, nftMarketAddress } from '../config';

import NFT from '../artifacts/contracts/NFT.sol/NFT.json'
import Market from '../artifacts/contracts/NFTMarket.sol/NFTMarket.json'

const IPFS_URL = 'https://ipfs.infura.io/ipfs/';

export default function CreateItem () {
    const [fileUrl, setFileUrl] = useState(null);
    const [formInput, updateFormInput] = useState({price: '', name: '', description: '' });

    const router = useRouter();

    async function onChange(e) {
        const file = e.target.files[0];
        try {
            const added = await client.add(
                file,
                {
                    progress: (prog) => console.log(`received: , ${prog}`)
                }
            );
            const url = IPFS_URL + added.path;
            setFileUrl(url);
        } catch(e) {
            console.log(e);
        }
    }

    async function createItem() {
        const {name, description, price } = formInput;
        if (!name || !description || !price) return;
        const data = JSON.stringify({
            name, description, image: fileUrl
        });
        
        try {
            const added = await client.add(data)
            const url = IPFS_URL + added.path;
            createSale(url);
        } catch (error) {
            console.log("Error uploading file : ", error)
        }
    }

    async function createSale() {
        const web3Modal = new Web3Modal();
        const connection = await web3Modal.connect();

        const provider = new ethers.providers.Web3Provider(connection);
        const signer = provider.getSigner();

        let contract = new ethers.Contract(nftAddress, NFT.abi, signer);
        let transaction = await contract.createToken(url);

        let tx = await transaction.wait();

        let event = tx.events[0]
        let value = event.args[2]
        let tokenId = value.toNumber();

        
    }
}