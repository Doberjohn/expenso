import React, { useState, useEffect } from 'react';
import { FlatList, NativeModules, NativeEventEmitter, StyleSheet } from 'react-native';
import { GestureHandlerRootView } from 'react-native-gesture-handler';
import TransactionRow from './TransactionRow';

const { TransactionBridge } = NativeModules;
const eventEmitter = new NativeEventEmitter(TransactionBridge);

interface Transaction {
  id: string;
  amount: number;
  type: 'expense' | 'income';
  category: {
    name: string;
    icon: string;
    color: string;
    bgColor: string;
    type: string;
  };
  note: string;
  paidBy: string;
  date: number;
}

interface Props {
  transactions?: Transaction[];
}

export default function TransactionList({ transactions: initialTransactions }: Props) {
  const [transactions, setTransactions] = useState<Transaction[]>(
    initialTransactions || []
  );

  useEffect(() => {
    const subscription = eventEmitter.addListener(
      'onTransactionsUpdate',
      (data: Transaction[]) => {
        setTransactions(data);
      }
    );
    return () => subscription.remove();
  }, []);

  const handleDelete = (id: string) => {
    TransactionBridge.deleteTransaction(id);
  };

  return (
    <GestureHandlerRootView>
      <FlatList
        data={transactions}
        keyExtractor={(item) => item.id}
        renderItem={({ item }) => (
          <TransactionRow
            transaction={{
              ...item,
              date: new Date(item.date),
            }}
            onDelete={handleDelete}
          />
        )}
        contentContainerStyle={styles.list}
        showsVerticalScrollIndicator={false}
      />
    </GestureHandlerRootView>
  );
}

const styles = StyleSheet.create({
  list: { gap: 12, paddingBottom: 24 },
});
