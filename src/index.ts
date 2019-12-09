import Web3 from 'web3';
import {Subscription} from 'web3-core-subscriptions';
import Redis from 'ioredis';
import _ from 'lodash';
import {Observable} from 'rxjs';

const ethUrl = process.env.PARITY_URL || 'http://localhost:8545';
const web3 = new Web3(ethUrl);

const redisUrl = process.env.REDIS_URL || 'redis://127.0.0.1:6379';
const redis = new Redis(redisUrl);

const pendingTransactions = new Observable<string>(observer => {
    let pendingTransactionsSubscription:Subscription<string> = null;
    const subscribe = function subscribe() {
        console.log(`subscribing to ${ethUrl}`);
        if (pendingTransactionsSubscription) {
            pendingTransactionsSubscription.unsubscribe();
        }
        pendingTransactionsSubscription = web3.eth.subscribe('pendingTransactions', function onSubscribe(error, result) {
            //console.log(error || result);
        }).on('data', function onPendingTransaction(data) {
            console.log(`onPendingTransaction: ${JSON.stringify(data)}`);
            observer.next(data);
        }).on('error', function onPendingTransactionError(error) {
            console.log(`onPendingTransactionError: ${JSON.stringify(error)}`);
            // todo do we need to resubscribe on error or does web3 handle this?
            subscribe();
        });
    }
    subscribe();
    return function unsubscribe() {
        if (pendingTransactionsSubscription) {
            pendingTransactionsSubscription.unsubscribe();
        }
    };
});

pendingTransactions.subscribe(data => {
    // todo fetch more data than just the hash
    //const params = _(data).toPairs().flatten().value();
    const params = ['hash', data];
    redis.xadd('rdr', '*', ...params);
});
